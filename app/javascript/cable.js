import { createCable, fetchTokenFromHTML } from "@anycable/web"

export default createCable({
  protocol: 'actioncable-v1-ext-json',
  tokenRefresher: fetchTokenFromHTML(),
});
