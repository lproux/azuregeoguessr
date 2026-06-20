targetScope = 'subscription'

// =====================================================================
// AzureGuessr — infrastructure as code (azd-compatible)
// Provisions a resource group + an Azure Static Web App to host the game.
// =====================================================================

@minLength(1)
@maxLength(64)
@description('Name of the environment / workload. Used to derive resource names. azd sets this from AZURE_ENV_NAME.')
param environmentName string

@description('Primary location for the resource group.')
param location string = deployment().location

@description('Region for the Static Web App (must be a SWA-supported region).')
@allowed([
  'westus2'
  'centralus'
  'eastus2'
  'westeurope'
  'eastasia'
])
param staticWebAppLocation string = 'westeurope'

@description('SKU for the Static Web App. Free covers casual play; Standard adds SLA, custom auth and more.')
@allowed([
  'Free'
  'Standard'
])
param staticWebAppSku string = 'Free'

// Deterministic, collision-resistant suffix for globally-unique names.
var resourceToken = toLower(uniqueString(subscription().id, environmentName, location))
var tags = {
  'azd-env-name': environmentName
}

resource rg 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: 'rg-${environmentName}'
  location: location
  tags: tags
}

module web 'staticwebapp.bicep' = {
  name: 'staticwebapp'
  scope: rg
  params: {
    name: 'swa-${resourceToken}'
    location: staticWebAppLocation
    skuName: staticWebAppSku
    // azd uses the azd-service-name tag to match this resource to the 'web' service in azure.yaml.
    tags: union(tags, { 'azd-service-name': 'web' })
  }
}

output AZURE_LOCATION string = location
output RESOURCE_GROUP_ID string = rg.id
output WEB_NAME string = web.outputs.name
output WEB_URI string = web.outputs.uri
output AZUREGUESSR_URL string = web.outputs.uri
