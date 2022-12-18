@sys.description('The Web App name.')
@minLength(3)
@maxLength(30)
param appServiceAppNameprodb string
@sys.description('The Web App name.')
@minLength(3)
@maxLength(30)
param appServiceAppNameprodf string 
@sys.description('The App Service Plan name.')
@minLength(3)
@maxLength(30)
param appServicePlanNameprod string 
@sys.description('The Web App name.')
@minLength(3)
@maxLength(30)
param appServiceAppNamedevb string 
@minLength(3)
@maxLength(30)
param appServiceAppNamedevf string 
@sys.description('The App Service Plan name.')
@minLength(3)
@maxLength(30)
param appServicePlanNamedev string
@sys.description('The Storage Account name.')
@minLength(3)
@maxLength(30)
param storageAccountName string = 'jrubialesstorage'
@allowed([
  'nonprod'
  'prod'
  ])

param environmentType string = 'nonprod'
param location string = resourceGroup().location

@secure()
param dbhost string
@secure()
param dbuser string
@secure()
param dbpass string
@secure()
param dbname string


var storageAccountSkuName = (environmentType == 'prod') ? 'Standard_GRS' : 'Standard_LRS'  

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-05-01' = {
    name: storageAccountName
    location: location
    sku: {
      name: storageAccountSkuName
    }
    kind: 'StorageV2'
    properties: {
      accessTier: 'Hot'
    }
  }

 

module appServiceprodbe 'modules/appStuff.bicep' = if (environmentType == 'prod') {
  name: 'appServiceprodbe'
  params: { 
    location: location
    appServiceAppName: appServiceAppNameprodb
    appServicePlanName: appServicePlanNameprod
    runtimeStack: 'Python|3.10'
    command: ''
    dbhost: dbhost
    dbuser: dbuser
    dbpass: dbpass
    dbname: dbname
  }
}

module appServiceprodfe 'modules/appStuff.bicep' = if (environmentType == 'prod') {
  name: 'appServiceprodfe'
  params: { 
    location: location
    appServiceAppName: appServiceAppNameprodf
    appServicePlanName: appServicePlanNameprod
    runtimeStack: 'Node|14-lts'
    command: 'pm2 serve /home/site/wwwroot/dist --no-daemon --spa'
    dbhost: dbhost
    dbuser: dbuser
    dbpass: dbpass
    dbname: dbname    
  }
}

module appServicedevbe 'modules/appStuff.bicep' = if (environmentType == 'nonprod') {
  name: 'appServicedevbe'
  params: { 
    location: location
    appServiceAppName: appServiceAppNamedevb
    appServicePlanName: appServicePlanNamedev
    runtimeStack: 'Python|3.10'
    command: ''
    dbhost: dbhost
    dbuser: dbuser
    dbpass: dbpass
    dbname: dbname
  }
}

module appServicedevfe 'modules/appStuff.bicep' = if (environmentType == 'nonprod') {
  name: 'appServicedevfe'
  params: { 
    location: location
    appServiceAppName: appServiceAppNamedevf
    appServicePlanName: appServicePlanNamedev
    runtimeStack: 'Node|14-lts'
    command: 'pm2 serve /home/site/wwwroot/dist --no-daemon --spa'
    dbhost: dbhost
    dbuser: dbuser
    dbpass: dbpass
    dbname: dbname
  }
}

output appServiceAppHostNamebackend string = (environmentType == 'prod') ? appServiceprodbe.outputs.appServiceAppHostName : appServicedevbe.outputs.appServiceAppHostName
output appServiceAppHostNamefrontend string = (environmentType == 'prod') ? appServiceprodfe.outputs.appServiceAppHostName : appServicedevfe.outputs.appServiceAppHostName
