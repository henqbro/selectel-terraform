variable "selectel_account_id" {
  description = "Номер аккаунта Selectel"
  type        = string
}

variable "selectel_username" {
  description = "Имя сервисного пользователя"
  type        = string
}

variable "selectel_password" {
  description = "Пароль сервисного пользователя"
  type        = string
  sensitive   = true
}

variable "ssh_public_key_path" {
  description = "Путь к публичному SSH-ключу"
  type        = string
  default     = ""
}

variable "project_id" {
  description = "UUID существующего проекта Selectel"
  type        = string
}
