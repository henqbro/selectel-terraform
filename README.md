# 🖥️ selectel-terraform

Инфраструктурный проект для автоматического развёртывания
виртуальной машины в **Selectel Cloud** с помощью Terraform.

---

## 🗂 Структура проекта

```
selectel-terraform/
├── main.tf               # Основная конфигурация Terraform
├── outputs.tf            # Выходные значения (IP, ID ресурсов)
├── providers.tf          # Настройка провайдера Selectel
├── variables.tf          # Объявление переменных
├── terraform.tfvars      # Значения переменных (токены, ID проекта)
└── README.md
```

---

## 🚀 Быстрый старт

```bash
terraform init
terraform plan
terraform apply
```

---

## 🔧 Переменные (`terraform.tfvars`)

| Переменная | Описание |
|---|---|
| `sel_token` | API-токен Selectel |
| `sel_account` | ID аккаунта Selectel |
| `sel_project_id` | ID проекта |
| `region` | Регион (например, `ru-3`) |


---

## 🆚 Отличия: Yandex Cloud vs Selectel

| | Yandex Cloud | Selectel |
|---|---|---|
| **Провайдер** | `yandex-cloud/yandex` | `selectel/selectel` |
| **Авторизация** | OAuth-токен или сервисный аккаунт | API-токен аккаунта |
| **Ресурс ВМ** | `yandex_compute_instance` | `selectel_vpc_server_v1` |
| **Сеть** | `yandex_vpc_network` + `yandex_vpc_subnet` | `selectel_vpc_network_v1` + `selectel_vpc_subnet_v1` |
| **cloud-init** | `metadata.user-data` | `user_data` |
| **Образы** | `yandex_compute_image` (data source) | `selectel_vpc_image_v1` (data source) |
| **Уникальная сущность** | `folder_id` — папка внутри облака | `project_id` — проект внутри аккаунта |

**Главное отличие:** в Yandex Cloud иерархия `облако → папка → ресурсы`,
в Selectel — `аккаунт → проект → ресурсы`. Логика Terraform одинакова,
меняются только названия ресурсов и способ авторизации.

---

## 📌 Цель проекта

Пет-проект для отработки навыков:
**IaC (Terraform)** · **Selectel Cloud** · **OpenStack**
