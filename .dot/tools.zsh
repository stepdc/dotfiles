# kubectl
if [ $commands[kubectl] ]; then
  source <(kubectl completion zsh)
fi

# minikube
if [ $commands[minikube] ]; then
  source <(minikube completion zsh)
fi
