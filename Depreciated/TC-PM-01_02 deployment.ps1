#Written by Benjamin Morgan benjamin.s.morgan@outlook.com with asstance from https://github.com/Azure
#Code written for training purposes AZ-104 exam. Not for commercial use!
function Deploy-TC-PM-01_02 #Deploys 2 VMs into 2 Azure RGs using templates stored in https://github.com/benjaminsmorgan/Azrue-ARM
{
    [CmdletBinding()]
    param 
    (
        # Define New Resource Group 1 Name
        [Parameter(Mandatory=$true, Position=0)]
            [string] 
            $AZRG1,
        # Define New Resource Group 2 Name
        [Parameter(Mandatory=$true, Position=1)]
            [string] 
            $AZRG2            
    )
    Begin{
    $tags =@{"Type"="VMs"} #Tag enforcement policy is set on the subscription, all resource groups require a Tag of "Type"
    $Template = "https://raw.githubusercontent.com/benjaminsmorgan/Azrue-ARM/main/Server2019template.json" #Template for the deployment of required assets, specfic configurations are loaded in the parameters
    $Param1 = "https://raw.githubusercontent.com/benjaminsmorgan/Azrue-ARM/main/TC-PM-01.parameters.json" #Parameters for TC-PM-01
    $Param2 = "https://raw.githubusercontent.com/benjaminsmorgan/Azrue-ARM/main/TC-PM-02.parameters.json" #Parameters for TC-PM-02
    New-AzResourceGroup -Name $AZRG1 -Location 'eastus' -Tag $tags #Creation of RG1
    New-AzResourceGroup -Name $AZRG2 -Location 'eastus' -Tag $tags #Creation of RG2
    New-AzResourceGroupDeployment -ResourceGroupName $AZRG1 -TemplateUri $Template -TemplateParameterUri $Param1 #Deployment of TC-PM-01
    New-AzResourceGroupDeployment -ResourceGroupName $AZRG2 -TemplateUri $Template -TemplateParameterUri $Param2 #Deployment of TC-PM-02
    }
}
function Connect-TC-PM-01_02 { # Connects to the 2 VMs using their new IP address, the username spelled out in the related template and the password from the Azure Keyvault
    [CmdletBinding()]
    param 
    (
        # User input of Resource Group 1 Name
        [Parameter(Mandatory=$true, Position=0)]
            [string] 
            $AZRG1name,
        # User input of Resource Group 2 Name
        [Parameter(Mandatory=$true, Position=1)]
            [string] 
            $AZRG2name           
    )
    Begin{
        $AZRG1 = (Get-AzResourceGroup -ResourceGroupName $AZRG1name) # Updates user input to match AZRG to actual RG
        $AZRG2 = (Get-AzResourceGroup -ResourceGroupName $AZRG2name) # Updates user input to match AZRG to actual RG
        $AZVMIP1 = (Get-AzPublicIpAddress -ResourceGroupName $AZRG1.ResourceGroupName).IpAddress # Finds and pulls public IP address for server in RG (Only pulls 1 per RG)
        $AZVMIP2 = (Get-AzPublicIpAddress -ResourceGroupName $AZRG2.ResourceGroupName).IpAddress # Finds and pulls public IP address for server in RG (Only pulls 1 per RG)
        $AZVMUSR1 = $AZVMIP1 + "\morganbs" # Creates variable for local adm account on VM
        $AZVMUSR2 = $AZVMIP2 + "\morganbs" # Creates variable for local adm account on VM
        $AZVMPASS1= (Get-AzKeyVaultSecret -VaultName morganbskeyvault -Name "TC-PM-01").SecretValueText # Pulls secret  from Azure vault and assigns to varible
        $AZVMPASS2= (Get-AzKeyVaultSecret -VaultName morganbskeyvault -Name "TC-PM-02").SecretValueText # Pulls secret  from Azure vault and assigns to varible
        cmdkey /generic:TERMSRV/$AZVMIP1 /user:$AZVMUSR1 /pass:$AZVMPASS1 #assigns variables to RDC session
        mstsc /v:$AZVMIP1 #Starts RDC connection to TC-PM-01
        cmdkey /generic:TERMSRV/$AZVMIP2 /user:$AZVMUSR2 /pass:$AZVMPASS2 #assigns variables to RDC session
        mstsc /v:$AZVMIP2 #Starts RDC connection to TC-PM-02
    }
}
function Remove-TC-PM-01_02 {
    [CmdletBinding()]
    param 
    (
        # User input of Resource Group 1 Name
        [Parameter(Mandatory=$true, Position=0)]
            [string] 
            $AZRG1,
        # User input of Resource Group 1 Name
        [Parameter(Mandatory=$true, Position=1)]
            [string] 
            $AZRG2            
    )
    Begin{
        Remove-AzResourceGroup -Name $AZRG1 -force  #Removes RG1
        Remove-AzResourceGroup -Name $AZRG2 -force #Removes RG2
    }
}
        