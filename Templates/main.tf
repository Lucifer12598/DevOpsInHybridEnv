
locals {
  resource_group="HybridEnv1"
  location="East US" 
  key_vault_name="Secrets" 
  key_vault_RG="terraformRG"
  key_vault_secreat_name="DBpassword"
  ASP_name="DevOpsInHybridEnv-plan"
  web_app_name="DevOpsInHybridEnv"
  sql_server_name="hybrid-server"
  sql_db_name="DevOpsInHybridEnv-db"
  sql_admin_user_name="dbadmin"

}
/*data "azurerm_client_config" "current" {}

data "azurerm_key_vault" "MySecreat" {
  name                = local.key_vault_name
  resource_group_name = local.key_vault_RG
}
data "azurerm_key_vault_secret" "DBpassword" {
  name         = local.key_vault_secreat_name
  key_vault_id = data.azurerm_key_vault.MySecreat.id
}
*/
resource "azurerm_resource_group" "app_grp"{
  name=local.resource_group
  location=local.location
}

resource "azurerm_app_service_plan" "app_plan" {
  name                = local.ASP_name
  location            = azurerm_resource_group.app_grp.location
  resource_group_name = azurerm_resource_group.app_grp.name
  sku {
    tier = "Basic"
    size = "B1"
  }
}

resource "azurerm_app_service" "webapp" {
  name                = local.web_app_name
  location            = azurerm_resource_group.app_grp.location
  resource_group_name = azurerm_resource_group.app_grp.name
  app_service_plan_id = azurerm_app_service_plan.app_plan.id
     
  depends_on=[azurerm_app_service_plan.app_plan]
}

resource "azurerm_sql_server" "app_server" {
  name                         = local.sql_server_name
  resource_group_name          = azurerm_resource_group.app_grp.name
  location                     = local.location  
  version             = "12.0"
  administrator_login          = local.sql_admin_user_name
  administrator_login_password = "Azure123"
}

resource "azurerm_sql_database" "app_db" {
  name                = local.sql_db_name
  resource_group_name = azurerm_resource_group.app_grp.name
  location            = local.location  
  server_name         = azurerm_sql_server.app_server.name
   depends_on = [
     azurerm_sql_server.app_server
   ]
}

resource "azurerm_sql_firewall_rule" "app_server_firewall_rule_Azure_services" {
  name                = "app-server-firewall-rule-Allow-Azure-services"
  resource_group_name = azurerm_resource_group.app_grp.name
  server_name         = azurerm_sql_server.app_server.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"
  depends_on=[
    azurerm_sql_server.app_server
  ]
}

