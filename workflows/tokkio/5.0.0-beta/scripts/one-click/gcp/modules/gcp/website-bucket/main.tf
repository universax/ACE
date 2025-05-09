
resource "google_storage_bucket" "this" {
  name                        = format("%s-web-assets", var.name)
  location                    = var.location
  force_destroy               = var.force_destroy
  uniform_bucket_level_access = true
  website {
    main_page_suffix = var.website_main_page_suffix
    not_found_page   = var.website_not_found_page
  }
  dynamic "custom_placement_config" {
    # ASIA1 / EUR1 / NAM4 など固定 Dual-Region のときは生成しない
    for_each = contains(["ASIA1","EUR1","NAM4"], upper(var.location)) ? [] : [1]

    content {
      data_locations = [
        upper(var.region),
        upper(var.alternate_region)
      ]
    }
  }
}