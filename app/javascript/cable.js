import { createCable, fetchTokenFromHTML } from "@anycable/web"

export default createCable({tokenRefresher: fetchTokenFromHTML()});
