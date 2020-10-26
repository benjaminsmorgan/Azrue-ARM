function TC-PM-01_02_Deploy 
{
    [CmdletBinding()]
    param 
    (
        # Define New Resource Group 1
        [Parameter(Mandatory=$true, Position=0)]
            [string] 
            $AZRG1,
        # Define New Resource Group 2
        [Parameter(Mandatory=$true, Position=1)]
            [string] 
            $AZRG2            
    )
    Begin{
    #$AZRG3 = "The_Taco_King_3" #Resourcegroup for TC-PM-01
    #$AZRG4 = "The_Taco_King_4" #Resourcegroup for TC-PM-02
    $tags =@{"Type"="VMs"} #Tag enforcement policy is set on the subscription, all resource groups require a Tag of "Type"
    $Template = "https://raw.githubusercontent.com/benjaminsmorgan/Azrue-ARM/main/Win16template.json" #Template for the deployment of required assets, specfic configurations are loaded in the parameters
    $Param1 = "https://raw.githubusercontent.com/benjaminsmorgan/Azrue-ARM/main/TC-PM-01.parameters.json" #Parameters for TC-PM-01
    $Param2 = "https://raw.githubusercontent.com/benjaminsmorgan/Azrue-ARM/main/TC-PM-02.parameters.json" #Parameters for TC-PM-02
    New-AzResourceGroup -Name $AZRG1 -Location 'eastus' -Tag $tags #Creation of RG1
    New-AzResourceGroup -Name $AZRG2 -Location 'eastus' -Tag $tags #Creation of RG2
    New-AzResourceGroupDeployment -ResourceGroupName $AZRG1 -TemplateUri $Template -TemplateParameterUri $Param1 #Deployment of TC-PM-01
    New-AzResourceGroupDeployment -ResourceGroupName $AZRG2 -TemplateUri $Template -TemplateParameterUri $Param2 #Deployment of TC-PM-02
    }
}