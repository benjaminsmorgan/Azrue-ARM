#Written by Benjamin Morgan benjamin.s.morgan@outlook.com with asstance from https://github.com/Azure
#Code written for training purposes AZ-104 exam. Not for commercial use!
function Training-Deploy-WinVM { #Deploys up to 4 VMs into 4 Azure RGs using templates stored in https://github.com/benjaminsmorgan/Azrue-ARM Resources are deployed to EastUS
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
            Write-Host "Please Provide Up To 4 Resource Group Names for Deployment"
            Write-Host "Example: Training-Deploy-WinVM TacoGroup1 TacoGroup2 TacoGroup3 TacoGroup4 "
            Break # Terminates Script
        }       
            else {
                New-AzResourceGroup -Name $AZRG1 -Location 'eastus' -Tag $tags #Creation of RG1
                New-AzResourceGroupDeployment -ResourceGroupName $AZRG1 -TemplateUri $Template -TemplateParameterUri $Param1 #Deployment of TC-PM-01
                #Write-Host $AZRG1 # This line is used for user input validation testing for If Else statements. Add # to the 2 line above and remove # from beginning of this line
            }
        if (!$AZRG2) {
            Write-Host "No Additional Parameters Provided, Ending Deployment"
            Break
        }
            else {
                New-AzResourceGroup -Name $AZRG2 -Location 'eastus' -Tag $tags #Creation of RG2
                New-AzResourceGroupDeployment -ResourceGroupName $AZRG2 -TemplateUri $Template -TemplateParameterUri $Param2 #Deployment of TC-PM-02
                #Write-Host $AZRG1 # This line is used for user input validation testing for If Else statements. Add # to the 2 line above and remove # from beginning of this line
            }
        if (!$AZRG3) {
            Write-Host "No Additional Parameters Provided, Ending Deployment"
            Break
        }
            else {
                New-AzResourceGroup -Name $AZRG3 -Location 'eastus' -Tag $tags #Creation of RG3
                New-AzResourceGroupDeployment -ResourceGroupName $AZRG3 -TemplateUri $Template -TemplateParameterUri $Param3 #Deployment of TC-PM-03
                #Write-Host $AZRG1 # This line is used for user input validation testing for If Else statements. Add # to the 2 line above and remove # from beginning of this line
            }
        if (!$AZRG4) {
            Write-Host "No Additional Parameters Provided, Ending Deployment"
            Break
        }
            else {
                New-AzResourceGroup -Name $AZRG4 -Location 'eastus' -Tag $tags #Creation of RG4
                New-AzResourceGroupDeployment -ResourceGroupName $AZRG4 -TemplateUri $Template -TemplateParameterUri $Param4 #Deployment of TC-PM-04
                #Write-Host $AZRG1 # This line is used for user input validation testing for If Else statements. Add # to the 2 line above and remove # from beginning of this line
            }
    }
}
function Training-connect-RDC { # Connects upto 4 VMs based of resource group name and IP address, the username spelled out in the related template and the password from the Azure Keyvault
    [CmdletBinding()]
    param 
    (
        ## Defines parameters of the function
        [Parameter(Mandatory=$true, Position=0)]
            [string] $AZRG1,
        [Parameter(Mandatory=$False, Position=1)] # User input of resource group 2 Name
            [string] $AZRG2,
        [Parameter(Mandatory=$False, Position=2)] # User input of resource group 3 Name
            [string] $AZRG3,   
        [Parameter(Mandatory=$False, Position=3)] # User input of resource group 4 Name
            [string] $AZRG4
            ## End of parameters definitions            
    )
    Begin{
        # First parameter run
        $AZRG1Name = (Get-AzResourceGroup -ResourceGroupName $AZRG1) # Updates user input to match AZRG to actual RG
        $AZRG1Secretname = (Get-AzResource -ResourceGroupName $AZRG1 -ResourceType Microsoft.Compute/virtualMachines).Name # Provides the name of the secret within the keyvault (Matched to the VM name)
        $AZVMPASS1= (Get-AzKeyVaultSecret -VaultName morganbskeyvault -Name $AZRG1Secretname).SecretValueText # Retrieves the secret value text using the name pulled from the VM
        $AZVMIP1 = (Get-AzPublicIpAddress -ResourceGroupName $AZRG1Name.ResourceGroupName).IpAddress # Gets the public IP address of the VM (only works for a single public ID address with the RG)
        $AZVMUSR1 = $AZVMIP1 + "\morganbs" # Creates variable for local adm account on VM
        cmdkey /generic:TERMSRV/$AZVMIP1 /user:$AZVMUSR1 /pass:$AZVMPASS1 #assigns variables to RDC session
        mstsc /v:$AZVMIP1 #Starts RDC connection to first listed server
        # End first parameter run
        # Begin additional parameter runs if present
        if (!$AZRG2) { # Check for additional parameters
            Write-Host "No Additional Parameters Provided, Ending Script"
            Break # Terminates Script
        }
            else {
                $AZRG2Name = (Get-AzResourceGroup -ResourceGroupName $AZRG2) # Updates user input to match AZRG to actual RG
                $AZRG2Secretname = (Get-AzResource -ResourceGroupName $AZRG2 -ResourceType Microsoft.Compute/virtualMachines).Name # Provides the name of the secret within the keyvault (Matched to the VM name)
                $AZVMPASS2= (Get-AzKeyVaultSecret -VaultName morganbskeyvault -Name $AZRG2Secretname).SecretValueText # Retrieves the secret value text using the name pulled from the VM
                $AZVMIP2 = (Get-AzPublicIpAddress -ResourceGroupName $AZRG2Name.ResourceGroupName).IpAddress # Gets the public IP address of the VM (only works for a single public ID address with the RG)
                $AZVMUSR2 = $AZVMIP2 + "\morganbs" # Creates variable for local adm account on VM
                cmdkey /generic:TERMSRV/$AZVMIP2 /user:$AZVMUSR2 /pass:$AZVMPASS2 #assigns variables to RDC session
                mstsc /v:$AZVMIP2 #Starts RDC connection to next listed server
            }
        if (!$AZRG3) { # Check for additional parameters
            Write-Host "No Additional Parameters Provided, Ending Script"
            Break # Terminates Script
            }
            else {
                $AZRG3Name = (Get-AzResourceGroup -ResourceGroupName $AZRG3) # Updates user input to match AZRG to actual RG
                $AZRG3Secretname = (Get-AzResource -ResourceGroupName $AZRG3 -ResourceType Microsoft.Compute/virtualMachines).Name # Provides the name of the secret within the keyvault (Matched to the VM name)
                $AZVMPASS3= (Get-AzKeyVaultSecret -VaultName morganbskeyvault -Name $AZRG3Secretname).SecretValueText # Retrieves the secret value text using the name pulled from the VM
                $AZVMIP3 = (Get-AzPublicIpAddress -ResourceGroupName $AZRG3Name.ResourceGroupName).IpAddress # Gets the public IP address of the VM (only works for a single public ID address with the RG)
                $AZVMUSR3 = $AZVMIP3 + "\morganbs" # Creates variable for local adm account on VM
                cmdkey /generic:TERMSRV/$AZVMIP3 /user:$AZVMUSR3 /pass:$AZVMPASS3 #assigns variables to RDC session
                mstsc /v:$AZVMIP3 #Starts RDC connection to next listed server
            }
        if (!$AZRG4) { # Check for additional parameters
                Write-Host "No Additional Parameters Provided, Ending Script"
                Break # Terminates Script
            }
                else {
                    $AZRG4Name = (Get-AzResourceGroup -ResourceGroupName $AZRG4) # Updates user input to match AZRG to actual RG
                    $AZRG4Secretname = (Get-AzResource -ResourceGroupName $AZRG4 -ResourceType Microsoft.Compute/virtualMachines).Name # Provides the name of the secret within the keyvault (Matched to the VM name)
                    $AZVMPASS4= (Get-AzKeyVaultSecret -VaultName morganbskeyvault -Name $AZRG4Secretname).SecretValueText # Retrieves the secret value text using the name pulled from the VM
                    $AZVMIP4 = (Get-AzPublicIpAddress -ResourceGroupName $AZRG4Name.ResourceGroupName).IpAddress # Gets the public IP address of the VM (only works for a single public ID address with the RG)
                    $AZVMUSR4 = $AZVMIP4 + "\morganbs" # Creates variable for local adm account on VM
                    cmdkey /generic:TERMSRV/$AZVMIP4 /user:$AZVMUSR4 /pass:$AZVMPASS4 #assigns variables to RDC session
                    mstsc /v:$AZVMIP4 #Starts RDC connection to next listed server
                }    
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
        Write-Host $AZRG1" has been removed"
        if (!$AZRG2) {
            Break
        }
            else{
                Remove-AzResourceGroup -Name $AZRG2 -force #Removes RG2
                Write-Host $AZRG2" has been removed"
            }
        if (!$AZRG3) {
            Break
        }
            else{
                Remove-AzResourceGroup -Name $AZRG3 -force #Removes RG3
                Write-Host $AZRG3" has been removed"
            }
        if (!$AZRG4) {
            Break
        }
            else{
                Remove-AzResourceGroup -Name $AZRG4 -force #Removes RG4
                Write-Host $AZRG4" has been removed"
            }
    }
}
function Training-Deploy-Secret { # Deploys a new secret and value to listed Azure Keyvault
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
function Training-Deploy-ResourceLock {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true, Position=0)] # This value can only be CanNotDelete or ReadOnly (powershell will parse short versions at the time of this writing C or R)
            [string] $LockLevel,
        [Parameter(Mandatory=$true, Position=1)]
            [string] $AZRG1,
        [Parameter(Mandatory=$false, Position=2)]
            [string] $AZRG2,
        [Parameter(Mandatory=$false, Position=3)]
            [string] $AZRG3,
        [Parameter(Mandatory=$false, Position=4)]
            [string] $AZRG4
    )
    Begin 
    {
        $AZRG1Name = (Get-AzResourceGroup -Name $AZRG1).ResourceGroupName # Associates user input to a resource group
        New-AzResourceLock -LockLevel $LockLevel -LockNotes "This a predefined lock for training" -LockName $AZRG1" Lock" -ResourceGroupName $AZRG1Name -Force # Deploys resource lock to resource group
        if (!$AZRG2) { # Check for additional parameters
            Write-Host "No Additional Parameters Provided, Ending Script"
            Break # Terminates Script
        }
            else {
                $AZRG2Name = (Get-AzResourceGroup -Name $AZRG2).ResourceGroupName # Associates user input to a resource group
                New-AzResourceLock -LockLevel $LockLevel -LockNotes "This a predefined lock for training" -LockName $AZRG2" Lock" -ResourceGroupName $AZRG2Name -Force # Deploys resource lock to resource group
            }
        if (!$AZRG3) { # Check for additional parameters
            Write-Host "No Additional Parameters Provided, Ending Script"
            Break # Terminates Script
            }
            else {
                $AZRG3Name = (Get-AzResourceGroup -Name $AZRG3).ResourceGroupName # Associates user input to a resource group
                New-AzResourceLock -LockLevel $LockLevel -LockNotes "This a predefined lock for training" -LockName $AZRG3" Lock" -ResourceGroupName $AZRG3Name -Force # Deploys resource lock to resource group
            }
        if (!$AZRG4) { # Check for additional parameters
                Write-Host "No Additional Parameters Provided, Ending Script"
                Break # Terminates Script
            }
            else {
                $AZRG4Name = (Get-AzResourceGroup -Name $AZRG4).ResourceGroupName # Associates user input to a resource group
                New-AzResourceLock -LockLevel $LockLevel -LockNotes "This a predefined lock for training" -LockName $AZRG4" Lock" -ResourceGroupName $AZRG4Name -Force # Deploys resource lock to resource group
            }  
    }
}
function Training-Remove-ResourceLock { # This code needs a check against a lock not existing against a parameter
[CmdletBinding()]
    param (
        [Parameter(Mandatory=$true, Position=0)]
            [string] $AZRG1,
        [Parameter(Mandatory=$false, Position=1)]
            [string] $AZRG2,
        [Parameter(Mandatory=$false, Position=2)]
            [string] $AZRG3,
        [Parameter(Mandatory=$false, Position=3)]
            [string] $AZRG4
    )
    Begin
    {
        $AZRG1Name = (Get-AzResourceGroup -Name $AZRG1).ResourceGroupName # Associates user input to a resource group
        $lock1 = (Get-AzResourceLock -ResourceGroupName $AZRG1Name).resourceid # Pulls the resourceID for the resource lock from the listed resource group
        Remove-AzResourceLock -ResourceId $lock1 -force # Removes the resource lock from the group
        Write-Host $AZRG1Name"'s lock has been removed"
        if (!$AZRG2) { # Check for additional parameters
            Write-Host "No Additional Parameters Provided, Ending Script"
            Break # Terminates Script
        }
            else {
                $AZRG2Name = (Get-AzResourceGroup -Name $AZRG2).ResourceGroupName # Associates user input to a resource group
                $lock2 = (Get-AzResourceLock -ResourceGroupName $AZRG2Name).resourceid # Pulls the resourceID for the resource lock from the listed resource group
                Remove-AzResourceLock -ResourceId $lock2 -force # Removes the resource lock from the group
                Write-Host $AZRG2Name"'s lock has been removed"
            }
        if (!$AZRG3) { # Check for additional parameters
            Write-Host "No Additional Parameters Provided, Ending Script"
            Break # Terminates Script
        }
            else {
                $AZRG3Name = (Get-AzResourceGroup -Name $AZRG3).ResourceGroupName # Associates user input to a resource group
                $lock3 = (Get-AzResourceLock -ResourceGroupName $AZRG3Name).resourceid # Pulls the resourceID for the resource lock from the listed resource group
                Remove-AzResourceLock -ResourceId $lock3 -force # Removes the resource lock from the group
                Write-Host $AZRG3Name"'s lock has been removed"
            }
        if (!$AZRG4) { # Check for additional parameters
            Write-Host "No Additional Parameters Provided, Ending Script"
            Break # Terminates Script
        }
            else {
                $AZRG4Name = (Get-AzResourceGroup -Name $AZRG4).ResourceGroupName # Associates user input to a resource group
                $lock4 = (Get-AzResourceLock -ResourceGroupName $AZRG4Name).resourceid # Pulls the resourceID for the resource lock from the listed resource group
                Remove-AzResourceLock -ResourceId $lock4 -force # Removes the resource lock from the group
                Write-Host $AZRG4Name"'s lock has been removed"
            } 
    }
}
function Training-GetHelp { # This is a local help file to assist the operator on the use and required changes to this script to ensure functionality
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true, Position=0)]
            [string] $FunctionName
    )
    Begin
    {
        if ($FunctionName -like "Training-Deploy-W*") {
            Write-Host "**************************************************************************************************************************************************"
            Write-Host "The syntax of this command is 'Training-Deploy-WinVM RG1NAME RG2NAME RG3NAME RG4NAME'"
            Write-Host "This command deploys up to 4 resource group deployments"
            Write-Host "The script should be updated with the operators prefered Templates and Parameters files on github"
            Write-Host "In order for the Training-Connect-RDC function to work, the Parameters file needs to include the same Admin Username and the keyvault secret will need to match the VM Name"
            Write-Host "If the operator needs to run Templates or Parameters files locally, the commands themselves will need to be changed from URI to file"
            Write-Host "Ref: https://docs.microsoft.com/en-us/powershell/module/az.resources/new-azdeployment?view=azps-5.0.0#example-1--use-a-custom-template-and-parameter-file-to-create-a-deployment"    
            Write-Host "**************************************************************************************************************************************************"
        }
        elseif ($FunctionName -like "Training-c*") {
            Write-Host "**************************************************************************************************************************************************"
            Write-Host "The syntax of this command is 'Training-Connect-RDC RG1NAME RG2NAME RG3NAME RG4NAME'"
            Write-Host "This command will need to updated to the operators keyvault variables"
            Write-Host "In addition, the operator will need to update the Admin user account name to match the parameters file"
            Write-Host "This command is stuctured to pull the Secret from a keyvault using the VM name as the Secret name, any changes to this schema will need to be manually changed"
            Write-Host "The order of connection is based off the order of the operaor input, this command uses the name of the RG to pull the needed info for the IP and VM name"
            Write-Host "This command will not function for a RG with more than one public IP server"
            Write-Host "**************************************************************************************************************************************************"
        }
        elseif ($FunctionName -like "Training-Deploy-R*") {
            Write-Host "**************************************************************************************************************************************************"
            Write-Host "The syntax of this command is 'Training-Deploy-ResourceLock R(or C) RG1NAME RG2NAME RG3NAME RG4NAME'"
            Write-Host "No edits are needed for this command to run"
            Write-Host "Will only apply a CanNotDelete or ReadOnly lock to a listed resource group"
            Write-Host "The letters 'C' and 'R' can be used inleiu of CanNotDelete and ReadOnly, There is no correction done in this script for this"
            Write-Host "The operator should update the hard coded message of the lock to match their schema"
            Write-Host "**************************************************************************************************************************************************"
        }
        elseif ($FunctionName -like "Training-Deploy-Secret"){
            Write-Host "**************************************************************************************************************************************************"
            Write-Host "The syntax of this command is 'Training-Deploy-Secret SECRETVALUE SECRETNAME"
            Write-Host "This funtion has hardcoded references to a keyvault that will need to changed by the operator to function"
            Write-Host "If a secret name already exists, the secret value of this command will override the existing value, no prompt will be provided"
            Write-Host "MS has noted that changes to the KeyVault will occur soon that may break functionality"
            Write-Host "**************************************************************************************************************************************************"
        }
        elseif ($FunctionName -like "Training-D*") {
            Write-Host "**************************************************************************************************************************************************"
            Write-Host "The Training-Deploy Commands are used for deploying Assets, locks, and Keys"
            Write-Host "Training-Deploy-WinVM is used for deploying servers from Github Templates and Parameters"
            Write-Host "Training-Deploy-ResourceLock is used to deploy CanNotDelete and Read only locks to a (Up to 4) resource group(s)"
            Write-Host "Training-Deploy-Secret is used to deploy a new secret to the keyvault within the command"
            Write-Host "**************************************************************************************************************************************************"
        }
        else {
            Write-Host "**************************************************************************************************************************************************"
            Write-Host "The Functions in this script are"
            Write-Host "Training-Deploy-WinVM"
            Write-Host "Training-Deploy-ResourceLock"
            Write-Host "Training-Deploy-Secret"
            Write-Host "Training-connect-RDC"
            Write-Host "Training-Remove-ResourceLock"
            Write-Host "Training-Remove-RGs"
            Write-Host "**************************************************************************************************************************************************"
            
        }
    }
}