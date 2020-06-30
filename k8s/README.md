#### K8s

``` kubectl apply -f k8s/ns.yml ```
``` kubectl apply -f k8s/redis.yml ```
``` kubectl apply -f k8s/go-app.yml```

Get NodePort 

``` kubectl get service go-app-service -n demo-ops -o json | jq .spec.ports[].nodePort ```

``` curl IP:NodePort ```

``` kubectl delete -f k8s/ns.yml ```
``` kubectl delete -f k8s/redis.yml ```
``` kubectl delete -f k8s/go-app.yml```
