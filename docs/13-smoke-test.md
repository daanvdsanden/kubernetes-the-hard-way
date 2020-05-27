# Smoke Test

In this lab you will complete a series of tasks to ensure your Kubernetes cluster is functioning correctly.

## Data Encryption

In this section you will verify the ability to [encrypt secret data at rest](https://kubernetes.io/docs/tasks/administer-cluster/encrypt-data/#verifying-that-data-is-encrypted).

Create a generic secret:

```
kubectl create secret generic kubernetes-the-hard-way \
  --from-literal="mykey=mydata"
```

Print a hexdump of the `kubernetes-the-hard-way` secret stored in etcd:

```
vagrant ssh controller-0 \
  --command "sudo ETCDCTL_API=3 etcdctl get \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/etcd/ca.pem \
  --cert=/etc/etcd/kubernetes.pem \
  --key=/etc/etcd/kubernetes-key.pem\
  /registry/secrets/default/kubernetes-the-hard-way | hexdump -C"
```

> output

```
00000000  2f 72 65 67 69 73 74 72  79 2f 73 65 63 72 65 74  |/registry/secret|
00000010  73 2f 64 65 66 61 75 6c  74 2f 6b 75 62 65 72 6e  |s/default/kubern|
00000020  65 74 65 73 2d 74 68 65  2d 68 61 72 64 2d 77 61  |etes-the-hard-wa|
00000030  79 0a 6b 38 73 3a 65 6e  63 3a 61 65 73 63 62 63  |y.k8s:enc:aescbc|
00000040  3a 76 31 3a 6b 65 79 31  3a 17 94 21 73 23 48 20  |:v1:key1:..!s#H |
00000050  1d 7c da 68 fe 0d eb a3  58 b6 41 21 8c 2d d4 91  |.|.h....X.A!.-..|
00000060  d1 7f 4a eb 65 c6 ae ce  9d d0 0c 40 32 71 ba 0b  |..J.e......@2q..|
00000070  0a ab b7 af 66 bd ad 46  6d 10 37 e4 ff 1c c6 74  |....f..Fm.7....t|
00000080  97 78 12 ac 33 af b8 74  0d c0 8f 4c 6e 0a 74 d9  |.x..3..t...Ln.t.|
00000090  6e 50 19 31 f4 56 0d 20  4d 35 16 ba 7a b7 c2 7e  |nP.1.V. M5..z..~|
000000a0  a7 f2 42 aa 61 0d c2 e1  ac 0b 93 c5 51 b5 17 05  |..B.a.......Q...|
000000b0  a6 84 da e3 86 90 43 6a  2e e2 12 5f 3e 9c 74 ea  |......Cj..._>.t.|
000000c0  f1 6a 84 13 f4 a0 1e 19  af 86 d1 36 d4 5f 00 37  |.j.........6._.7|
000000d0  a2 ef c2 99 bb 09 b0 32  bc 9d d2 e0 ab 46 d1 41  |.......2.....F.A|
000000e0  8b 4c 37 11 65 7a 30 3d  0f bf ba ef f3 9e 52 58  |.L7.ez0=......RX|
000000f0  47 87 6b a5 a2 a4 de 25  30 a7 fc a4 20 4f 9c 15  |G.k....%0... O..|
00000100  dc 56 77 98 42 59 99 7e  3a 28 53 84 af 07 4b 9a  |.Vw.BY.~:(S...K.|
00000110  40 fa 56 e1 c5 9f b3 ad  d7 54 37 f1 81 69 3c f3  |@.V......T7..i<.|
00000120  99 78 5c e3 f3 04 bd af  40 c7 de c8 3d 9d 5e be  |.x\.....@...=.^.|
00000130  40 e0 7e b9 1f d9 2e ee  1f 4c 83 18 d1 f1 f3 48  |@.~......L.....H|
00000140  98 c2 b8 b5 1a e1 0b 90  4f 0a                    |........O.|
0000014a
```

The etcd key should be prefixed with `k8s:enc:aescbc:v1:key1`, which indicates the `aescbc` provider was used to encrypt the data with the `key1` encryption key.

## Deployments

In this section you will verify the ability to create and manage [Deployments](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/).

Create a deployment for the [nginx](https://nginx.org/en/) web server:

```
kubectl create deployment nginx --image=nginx
```

List the pod created by the `nginx` deployment:

```
kubectl get pods -l app=nginx
```

> output

```
NAME                    READY   STATUS    RESTARTS   AGE
nginx-f89759699-zsdgp   1/1     Running   0          13s
```

### Port Forwarding

In this section you will verify the ability to access applications remotely using [port forwarding](https://kubernetes.io/docs/tasks/access-application-cluster/port-forward-access-application-cluster/).

Retrieve the full name of the `nginx` pod:

```
POD_NAME=$(kubectl get pods -l app=nginx -o jsonpath="{.items[0].metadata.name}")
```

Forward port `8080` on your local machine to port `80` of the `nginx` pod:

```
kubectl port-forward $POD_NAME 8080:80
```

> output

```
Forwarding from 127.0.0.1:8080 -> 80
Forwarding from [::1]:8080 -> 80
```

In a new terminal make an HTTP request using the forwarding address:

```
curl --head http://127.0.0.1:8080
```

> output

```
HTTP/1.1 200 OK
Server: nginx/1.17.10
Date: Wed, 27 May 2020 18:25:23 GMT
Content-Type: text/html
Content-Length: 612
Last-Modified: Tue, 14 Apr 2020 14:19:26 GMT
Connection: keep-alive
ETag: "5e95c66e-264"
Accept-Ranges: bytes
```

Switch back to the previous terminal and stop the port forwarding to the `nginx` pod:

```
Forwarding from 127.0.0.1:8080 -> 80
Forwarding from [::1]:8080 -> 80
Handling connection for 8080
^C
```

### Logs

In this section you will verify the ability to [retrieve container logs](https://kubernetes.io/docs/concepts/cluster-administration/logging/).

Print the `nginx` pod logs:

```
kubectl logs $POD_NAME
```

> output

```
127.0.0.1 - - [27/May/2020:18:25:23 +0000] "HEAD / HTTP/1.1" 200 0 "-" "curl/7.64.1" "-"
```

### Exec

In this section you will verify the ability to [execute commands in a container](https://kubernetes.io/docs/tasks/debug-application-cluster/get-shell-running-container/#running-individual-commands-in-a-container).

Print the nginx version by executing the `nginx -v` command in the `nginx` container:

```
kubectl exec -ti $POD_NAME -- nginx -v
```

> output

```
nginx version: nginx/1.17.10
```

## Services

In this section you will verify the ability to expose applications using a [Service](https://kubernetes.io/docs/concepts/services-networking/service/).

Expose the `nginx` deployment using a [NodePort](https://kubernetes.io/docs/concepts/services-networking/service/#type-nodeport) service:

```
kubectl expose deployment nginx --port 80 --type NodePort
```

> The LoadBalancer service type can not be used because your cluster is not configured with [cloud provider integration](https://kubernetes.io/docs/getting-started-guides/scratch/#cloud-provider). Setting up cloud provider integration is out of scope for this tutorial.

Retrieve the node port assigned to the `nginx` service:

```
NODE_PORT=$(kubectl get svc nginx \
  --output=jsonpath='{range .spec.ports[0]}{.nodePort}')
```


Make an HTTP request using the external IP address and the `nginx` node port:

```
for i in 0 1 2; do
  curl -I http://192.168.100.2${i}:${NODE_PORT}
done
```

> output

```
HTTP/1.1 200 OK
Server: nginx/1.17.10
Date: Wed, 27 May 2020 18:41:15 GMT
Content-Type: text/html
Content-Length: 612
Last-Modified: Tue, 14 Apr 2020 14:19:26 GMT
Connection: keep-alive
ETag: "5e95c66e-264"
Accept-Ranges: bytes

HTTP/1.1 200 OK
Server: nginx/1.17.10
Date: Wed, 27 May 2020 18:41:15 GMT
Content-Type: text/html
Content-Length: 612
Last-Modified: Tue, 14 Apr 2020 14:19:26 GMT
Connection: keep-alive
ETag: "5e95c66e-264"
Accept-Ranges: bytes

HTTP/1.1 200 OK
Server: nginx/1.17.10
Date: Wed, 27 May 2020 18:41:15 GMT
Content-Type: text/html
Content-Length: 612
Last-Modified: Tue, 14 Apr 2020 14:19:26 GMT
Connection: keep-alive
ETag: "5e95c66e-264"
Accept-Ranges: bytes
```

Next: [Cleaning Up](14-cleanup.md)
