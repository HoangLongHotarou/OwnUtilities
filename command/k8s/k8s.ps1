unction get {
    kubectl.exe get $args
}
function describe {
    kubectl.exe describe $args
}
function useContext {
    param (
        $name
    )
    kubectl.exe config use-context $name  
}
function getListContext {
    kubectl.exe config get-contexts
}
function getCurrentContext {
    kubectl.exe config current-context
}
function setNamespace {
    param (
        [string]$namespace
    )
    kubectl.exe config set-context --current --namespace=$namespace
}
function getCurrentNamespace {
    kubectl.exe config view --minify -o jsonpath='{..namespace}'
}

Set-Alias -Name k -Value kubectl
Set-Alias -Name kg -Value get
Set-Alias -Name kd -Value describe
Set-Alias -Name kuse -Value useContext
Set-Alias -Name kcur -Value getCurrentContext
Set-Alias -Name kset -Value setNamespace 
Set-Alias -Name kcurnsp -Value getCurrentNamespace