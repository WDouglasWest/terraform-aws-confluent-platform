resource "aws_security_group" "my_security_group" {
    count = var.enable_sg_creation ? 1 : 0
    name = var.sg_name
    description = "Confluent Platform - Schema Registry"
    vpc_id = var.vpc_id
    
    tags = var.tags
    
    #Schema Registry Related
    ingress {
        description = "SchemaReg - REST Interface - Internal"
        from_port   = 8081
        to_port     = 8081
        protocol    = "tcp"
        self        =  true
    }
    ingress {
        description = "SchemaReg - REST Interface - External"
        from_port   = 8081
        to_port     = 8081
        protocol    = "tcp"
        security_groups = combine([
            var.rest_proxy_sg_id,
            var.schema_registry_sg_id,
            var.control_center_sg_id
        ], var.kafka_connect_sg_ids, var.ksql_sg_ids)
    }
}

module "my_instance" {
    source = "../base_node"
    
    extra_template_vars = var.extra_template_vars
    
    servers = var.servers
    image_id = var.image_id
    instance_type = var.instance_type
    root_volume_size = var.root_volume_size
    key_pair = var.key_pair
    tags = var.tags
    subnet_id = var.subnet_id
    security_groups_ids = combine(var.security_groups_ids, [aws_security_group.my_security_group.id])
    dns_zone_id = var.dns_zone_id
    dns_ttl = var.dns_ttl
    name_template = var.name_template
    dns_template = var.dns_template
}