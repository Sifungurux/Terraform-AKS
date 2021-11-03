variable "rg_acr_name" {
    type    = string
}
variable "rg_acr_location" {
    type    = string
}
variable "acr_name" {
    type    = string
}
variable "acr_sku" {
    type    = string
    default = "Premium"
}
variable "admin_enabled" {
    type    = bool
}
variable "avil_loc_1" {
    type    = string
    default = "northeurope"
}
variable "avil_loc_2" {
    type    = string
    default = "westeurope"
}
variable "zone_redundancy" {
    type    = bool
}
