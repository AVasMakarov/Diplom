resource "yandex_iam_service_account" "sa-bucket" {
  name      = "sa-for-bucket"
}

resource "yandex_resourcemanager_folder_iam_member" "bucket-editor" {
  folder_id = var.folder_id
  role      = var.bucket-role.role-1 #выбрана роль админа, чтобы бакет удалялся при выполнении `terraform destroy`
  member    = "serviceAccount:${yandex_iam_service_account.sa-bucket.id}"
  depends_on = [yandex_iam_service_account.sa-bucket]
}

resource "yandex_iam_service_account_static_access_key" "sa-static-key" {
  service_account_id = yandex_iam_service_account.sa-bucket.id
  description        = "static access key for bucket"
}

resource "yandex_storage_bucket" "netology-bucket" {
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  bucket = var.bucket-name
  grant {
    id          = "${yandex_iam_service_account.sa-bucket.id}"
    type        = "CanonicalUser"
    permissions = ["FULL_CONTROL"]
  }
  force_destroy = true
}

resource "yandex_storage_object" "object-1" {
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  bucket = yandex_storage_bucket.netology-bucket.bucket
  key = var.object.object-1
  source = var.object.source-1
  depends_on = [yandex_storage_bucket.netology-bucket]
}