resource "azurerm_resource_group" "hubnetwork" {
    name="${var.azureregionshortnames["${var.hublocation}]}"-hub-rg
    location=var.hublocation
    tags {
        location=var.hublocation
        application="infra"
    }
}
resource "azurerm_network_security_group" "domaincontroller" {
    name="domain-contoller-NSG"
    location=azurerm_resource_group.hubnetwork.location
    resource_group_name=azurerm_resource_group.hubnetwork.name

    tags {
        application="DC-nsg"
    }
}
resource "azurerm_network_security_rule" "domaincontoller_DNS" {
  name                      = "DNS_InBound"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "53"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name=azurerm_resource_group.hubnetwork.name
  network_security_group_name=azurerm_network_security_group.domaincontroller.name
}

resource "azurerm_network_security_rule" "domaincontoller_ldap" {
    name                        = "LDAP_InBound"
  priority                    = 110
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "389"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name=azurerm_resource_group.hubnetwork.name
  network_security_group_name=azurerm_network_security_group.domaincontroller.name
}

resource "azurerm_network_security_rule" "domaincontroller_rpc" {
    name                        = "RPC_InBound"
  priority                    = 170
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "135"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name=azurerm_resource_group.hubnetwork.name
  network_security_group_name=azurerm_network_security_group.domaincontroller.name
}

resource "azurerm_virtual_network" "hubnetwork" {
    name= "${var.azureregionshortnames["${var.hublocation}"]}"-hub-network
    resource_group_name=azurerm_resource_group.hubnetwork.name
    location=var.hublocation
    adddress_space=var.hubaddressspace
    tags {
        enviornment=var.enviornment
        application="infra"
    }
}
resource "azurerm_subnet" "GatewaySubnet" {
    name="GatewaySubnet"
    resource_group_name=azurerm_resource_group.hubnetwork.name
    virtual_network_name=azurerm_virtual_network.hubnetwork.name
    address_prefix=var.gatewaysubnet
}
resource "azurerm_subnet" "domaincontrollersubnet" {
    name="domaincontroller-subnet"
    resource_group_name=azurerm_resource_group.hubnetwork.name
    virtual_network_name=azurerm_virtual_network.hubnetwork.name
    address_prefix=var.domaincontroller-subnet
    
}"
resource "azurerm_subnet_network_security_group_association" "DC-nsg-association" {
    subnet_id=azurerm_subnet.domaincontrollersubnet.id
    network_security_group_id=azurerm_network_security_group.domaincontroller.id
}
