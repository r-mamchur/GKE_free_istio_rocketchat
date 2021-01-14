# GKE. free Istio. Rocket chat.   

Terraform v0.14.3   
GKE 1.16.15-gke.4901   

Install Terraform, kubectl, istionctl and Helm.   
But you can deploy https://github.com/r-mamchur/GCE_desktop_vm, there is everything.    

Terraform deploy infrascrukture - GKE cluster.   

***kube-conf*** will be genereted by terraform from template. It allows access to the cluster (with kubectl, istioctl and helm).   
Copy it to `$HONE/.kube/config` or add `--kubeconfig="<Path>/kube-conf"` to command line.    

##### Istio deploy   
Look for details [https://istio.io/latest/docs/setup/getting-started](https://istio.io/latest/docs/setup/getting-started)   

```sh
istioctl install --set profile=demo -y
kubectl label namespace default istio-injection=enabled
```

****Rocket Chat**** with Helm, so far. It isn't a good idea. (WARNING: This chart is deprecated).    
Details:    
[https://docs.rocket.chat/installation/automation-tools/helm-chart](https://docs.rocket.chat/installation/automation-tools/helm-chart)   
[https://github.com/helm/charts/tree/master/stable/rocketchat](https://github.com/helm/charts/tree/master/stable/rocketchat)   

```sh
helm repo add stable https://charts.helm.sh/stable/

helm install rocket stable/rocketchat  \
   --set replicaCount=2 \
   --set mongodb.mongodbUsername=rocketchat,mongodb.mongodbPassword=changeme,mongodb.mongodbDatabase=rocketchat,mongodb.mongodbRootPassword=root-changeme \
   --kubeconfig="./kube-conf"
```

Open the application to outside traffic.    
```sh
# Get IP
export INGRESS_HOST=$(kubectl -n istio-system get service istio-ingressgateway \
      -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

echo $INGRESS_HOST

# Generate server certificat and key
openssl req -newkey rsa:2048 -sha256 -nodes -keyout ./server.key \
     -out ./server.crt -x509 -days 365 \
     -subj "/C=UA/ST=Prykarpattia/L=Ivano-Frankivsk/O=Rohy i kopyta Inc./OU=Camel/CN=$INGRESS_HOST/emailAddress=r_mamchur@ukr.net"

# Create a secret for the ingress gateway
kubectl create -n istio-system secret tls rocket-credential \
  --key=server.key \
  --cert=server.crt

# Configure a TLS ingress gateway -- http and https for test.     
cat <<EOF | kubectl apply --kubeconfig=./kube-conf -f -  
apiVersion: networking.istio.io/v1alpha3
kind: Gateway
metadata:
  name: rocket
spec:
  selector:
    istio: ingressgateway # use istio default controller
  servers:
  - port:
      number: 80
      name: http
      protocol: HTTP
    hosts:
    - "*"
  - port:
      number: 443
      name: https
      protocol: HTTPS
    tls:
      mode: SIMPLE
      credentialName: rocket-credential  
    hosts:
    - "*"
EOF

# Define the corresponding virtual service.   
cat <<EOF | kubectl apply --kubeconfig=./kube-conf -f -
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: rocket
spec:
  hosts:
    - "*"
  gateways:
    - rocket
  http:
  - match:
    - uri:
        prefix: /
    route:
    - destination:
        host: rocket-rocketchat
EOF
```    

Verify external access at address (http and https)   
      
      echo $INGRESS_HOST

If istio was installed as recommended   
`curl -L https://istio.io/downloadIstio | sh `   
_**samples**_ (directory) was installed, too.   

So, you can install _Kiali, Grafana, Jaeger_ and _Prometheus_ as   
```
kubectl apply -f samples/addons
kubectl rollout status deployment/kiali -n istio-system
```

##### Note:
If you want install Rocket Chat without istio, add _`ingress`_ and service have to be _`NodePort`_.     
Add to command line   
`--set service.type=NodePort --set ingress.enabled=true `

