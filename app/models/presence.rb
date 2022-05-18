# frozen_string_literal: true

class Presence
  class << self
    def instance
      @instance ||= new
    end

    delegate_missing_to :instance
  end

  private attr_reader :redis, :ttl

  PREFIX = "turbopresence"

  class RedisRollback < StandardError; end

  def initialize(ttl: 5.minutes)
    @ttl = ttl
    @redis = Redis.new
  end

  def add(channel_id, user_id)
    redis.multi do |r|
      r.incr("#{PREFIX}/#{channel_id}/#{user_id}")
      r.expire("#{PREFIX}/#{channel_id}/#{user_id}", ttl.seconds.from_now.to_i)
      r.zadd("#{PREFIX}/#{channel_id}", Time.now.to_i, user_id.to_s)
    end
  end

  def touch(channel_id, user_id)
    redis.zadd("#{PREFIX}/#{channel_id}", Time.now.to_i, user_id.to_s)
  end

  def remove(channel_id, user_id)
    counter_key = "#{PREFIX}/#{channel_id}/#{user_id}"

    redis.watch(counter_key) do |wr|
      val = wr.get(counter_key).to_i

      wr.multi do |r|
        r.decr(counter_key)
        r.zrem("#{PREFIX}/#{channel_id}", user_id) if val == 1
      end.tap do |reply|
        raise RedisRollback if reply.nil?
        wr.unwatch
      end
    end
  rescue RedisRollback
    retry
  end

  def for(channel_id)
    redis.zrange("#{PREFIX}/#{channel_id}", 0, -1)
  end

  def expire(channel_id)
    deadline = ttl.seconds.ago.to_i

    # First, retrieve expired ids — we may want to trigger
    # leave event for them
    expired_ids = redis.zrangebyscore("#{PREFIX}/#{channel_id}", "-inf", deadline)

    redis.zremrangebyscore(
      "#{PREFIX}/#{channel_id}",
      "-inf",
      deadline
    )

    expired_ids
  end
end
