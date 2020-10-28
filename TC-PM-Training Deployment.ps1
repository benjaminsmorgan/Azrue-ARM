#Written by Benjamin Morgan benjamin.s.morgan@outlook.com with asstance from https://github.com/Azure
#Code written for training purposes AZ-104 exam. Not for commercial use!
function Training-Deploy-WinVM #Deploys up to 4 VMs into 4 Azure RGs using templates stored in https://github.com/benjaminsmorgan/Azrue-ARM
{
    [CmdletBinding()]
    param 
    (
    ## Defines parameters of the function
        [Parameter(Mandatory=$False, Position=0)] # Define new resource group 1 name
            [string]$AZRG1,
        [Parameter(Mandatory=$False, Position=1)] # Define new resource group 2 name
            [string]$AZRG2,
        [Parameter(Mandatory=$False, Position=2)] # Define new resource group 3 name
            [string]$AZRG3,
        [Parameter(Mandatory=$False, Position=3)] # Define new resource group 4 name
            [string]$AZRG4 
    ## End of parameters definitions             
    )
    Begin{
    ## Begin $var creation
        $tags =@{"Type"="Training"} #Tag enforcement policy is set on the subscription, all resource groups require a Tag of "Type"
        $Template = "https://raw.githubusercontent.com/benjaminsmorgan/Azrue-ARM/main/Server2019template.json" #Template for the deployment of required assets, specfic configurations are loaded in the parameters
        $Param1 = "https://raw.githubusercontent.com/benjaminsmorgan/Azrue-ARM/main/TC-PM-01.parameters.json" #Parameters for TC-PM-01
        $Param2 = "https://raw.githubusercontent.com/benjaminsmorgan/Azrue-ARM/main/TC-PM-02.parameters.json" #Parameters for TC-PM-02
        $Param3 = "https://raw.githubusercontent.com/benjaminsmorgan/Azrue-ARM/main/TC-PM-03.parameters.json" #Parameters for TC-PM-03
        $Param4 = "https://raw.githubusercontent.com/benjaminsmorgan/Azrue-ARM/main/TC-PM-04.parameters.json" #Parameters for TC-PM-04
    ## End of $var creation
    ## Being resource and resource group deployment
        if (!$AZRG1) { # Checks for first parameter and ends script ff no parameters provided
            Write-Host "Please Provide Upto 4 Resource Group Names for Deployment"
            Write-Host "Example: Deploy-TrainingEn TacoGroup1 TacoGroup2 TacoGroup3 TacoGroup4 "
            Break
        }       
            else {
                New-AzResourceGroup -Name $AZRG1 -Location 'eastus' -Tag $tags #Creation of RG1
                New-AzResourceGroupDeployment -ResourceGroupName $AZRG1 -TemplateUri $Template -TemplateParameterUri $Param1 #Deployment of TC-PM-01
                #Write-Host $AZRG1 # This line is used for user input validation testing for If Else statements. Add # to the 2 line above and remove # from beginning of this line
            }
        if (!$AZRG2) {
            Write-Host "No Additional Prarameters Provided, Ending Deployment"
            Break
        }
            else {
                New-AzResourceGroup -Name $AZRG2 -Location 'eastus' -Tag $tags #Creation of RG2
                New-AzResourceGroupDeployment -ResourceGroupName $AZRG2 -TemplateUri $Template -TemplateParameterUri $Param2 #Deployment of TC-PM-02
                #Write-Host $AZRG1 # This line is used for user input validation testing for If Else statements. Add # to the 2 line above and remove # from beginning of this line
            }
        if (!$AZRG3) {
            Write-Host "No Additional Prarameters Provided, Ending Deployment"
            Break
        }
            else {
                New-AzResourceGroup -Name $AZRG3 -Location 'eastus' -Tag $tags #Creation of RG3
                New-AzResourceGroupDeployment -ResourceGroupName $AZRG3 -TemplateUri $Template -TemplateParameterUri $Param3 #Deployment of TC-PM-03
                #Write-Host $AZRG1 # This line is used for user input validation testing for If Else statements. Add # to the 2 line above and remove # from beginning of this line
            }
        if (!$AZRG4) {
            Write-Host "No Additional Prarameters Provided, Ending Deployment"
            Break
        }
            else {
                New-AzResourceGroup -Name $AZRG4 -Location 'eastus' -Tag $tags #Creation of RG4
                New-AzResourceGroupDeployment -ResourceGroupName $AZRG4 -TemplateUri $Template -TemplateParameterUri $Param4 #Deployment of TC-PM-04
                #Write-Host $AZRG1 # This line is used for user input validation testing for If Else statements. Add # to the 2 line above and remove # from beginning of this line
            }
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
function Training-Remove-RGs { # Removes listed resource groups (Provided the groups are not locked). Used to clean up the training enviornment quickly
    [CmdletBinding()]
    param 
    (
        # User input of Resource Group 1 Name
        [Parameter(Mandatory=$true, Position=0)]
            [string] $AZRG1,
        # User input of Resource Group 2 Name
        [Parameter(Mandatory=$false, Position=1)]
            [string] $AZRG2,
        # User input of Resource Group 3 Name
        [Parameter(Mandatory=$false, Position=2)]
            [string] $AZRG3,
        # User input of Resource Group 4 Name
        [Parameter(Mandatory=$false, Position=3)]
        [string] $AZRG4            
    )
    Begin{
        Remove-AzResourceGroup -Name $AZRG1 -force #Removes RG1
        Write-Host $AZRG1+" has been removed"
        if (!$AZRG2) {
            Break
        }
            else{
                Remove-AzResourceGroup -Name $AZRG2 -force #Removes RG2
                Write-Host $AZRG2+" has been removed"
            }
        if (!$AZRG3) {
            Break
        }
            else{
                Remove-AzResourceGroup -Name $AZRG3 -force #Removes RG3
                Write-Host $AZRG3+" has been removed"
            }
        if (!$AZRG4) {
            Break
        }
            else{
                Remove-AzResourceGroup -Name $AZRG4 -force #Removes RG4
                Write-Host $AZRG4+" has been removed"
            }
    }
}
function Training-AzureSecretKey {
    [CmdletBinding()]
    param 
    (
        # User input Secret Value
        [Parameter(Mandatory=$true, Position=0)]
            [string] $SecretValue,
        # User input for Secret Name
        [Parameter(Mandatory=$true, Position=1)]
            [string] $SecretName    
    )
    Begin
    {
        #$SecretValue = Read-Host "Enter the requested Password" -AsSecureString 
        $SecretHash = ConvertTo-SecureString -String $SecretValue -AsPlainText -Force
        $AZKV = (Get-AzKeyVault -Name morganbskeyvault).VaultName
        Set-AzKeyVaultSecret -VaultName $AZKV -Name $SecretName -SecretValue $SecretHash
    }
}        