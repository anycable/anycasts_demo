import { createConsumer, fetchTokenFromHTML } from "@anycable/web"

export default createConsumer({tokenRefresher: fetchTokenFromHTML()});
