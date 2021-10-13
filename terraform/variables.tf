variable "cloud_id" {
  description = "Cloud"
}
variable "folder_id" {
  description = "Folder"
}
variable "zone" {
  description = "Zone"
  # По-умолчанию ru-central1-a
  default = "ru-central1-a"
}
variable "public_key_path" {
  description = "Path to the public key used for ssh access"
}
variable "image_id" {
  description = "Disk image"
}
variable "subnet_id" {
  description = "Subnet"
}
variable "token" {
  description = "Yandex cloud access token"
}
variable "private_key_path" {
  description = "Path to the private key used for ssh access"
}
variable "vm_name" {
  description = "Yandex cloud vm (instance) name (only - without _)"
}
