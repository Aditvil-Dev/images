# DO NOT EDIT - this file is autogenerated by tfgen

output "summary" {
  value = merge(
    {
      basename(path.module) = {
        "ref"    = module.gitness.image_ref
        "config" = module.gitness.config
        "tags"   = ["latest"]
      }
  })
}

