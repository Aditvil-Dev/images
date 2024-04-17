# DO NOT EDIT - this file is autogenerated by tfgen

output "summary" {
  value = merge(
    {
      basename(path.module) = {
        "ref"    = module.install-cni.image_ref
        "config" = module.install-cni.config
        "tags"   = ["latest"]
      }
    },
    {
      basename(path.module) = {
        "ref"    = module.operator.image_ref
        "config" = module.operator.config
        "tags"   = ["latest"]
      }
    },
    {
      basename(path.module) = {
        "ref"    = module.pilot.image_ref
        "config" = module.pilot.config
        "tags"   = ["latest"]
      }
    },
    {
      basename(path.module) = {
        "ref"    = module.proxy.image_ref
        "config" = module.proxy.config
        "tags"   = ["latest"]
      }
  })
}

