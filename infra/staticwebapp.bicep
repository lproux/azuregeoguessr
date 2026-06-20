@description('Name of the Azure Static Web App resource.')
param name string

@description('Region for the Static Web App. Static Web Apps are only available in a subset of regions.')
@allowed([
  'westus2'
  'centralus'
  'eastus2'
  'westeurope'
  'eastasia'
])
param location string

@description('Tags applied to the resource (azd uses azd-service-name to target deployments).')
param tags object = {}

@description('SKU for the Static Web App. Free is enough for this game; Standard adds custom auth, SLA and more.')
@allowed([
  'Free'
  'Standard'
])
param skuName string = 'Free'

resource site 'Microsoft.Web/staticSites@2023-12-01' = {
  name: name
  location: location
  tags: tags
  sku: {
    name: skuName
    tier: skuName
  }
  properties: {
    // The site is deployed by azd / SWA CLI, not wired to a source-control build pipeline here.
    allowConfigFileUpdates: true
  }
}

output name string = site.name
output uri string = 'https://${site.properties.defaultHostname}'
output defaultHostname string = site.properties.defaultHostname
