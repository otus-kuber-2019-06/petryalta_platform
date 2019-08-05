# Networking in Kubernetes #

## Что сделано:

### Проверки доступности и готовности пода

В под WEB добавлены проверки readiness и leaveness
```yaml
    readinessProbe:
      httpGet:
        path: /index.html
        port: 80
    livenessProbe:
      tcpSocket: { port: 8000 }
```

### Deploy

Создан deployment [манифест](./web-deploy.yaml)

### ClusterIP

Создан ClusterIP для доступа к поду WEB. [манифест](./web-svc-cip.yaml)

### LoadBalance

#### MetalLB

Установил MetalLB [манифест](./metallb/metallb.yaml) и добавил [конфиг](./metallb/metallb-config.yaml)
Далее, создал [сервис](./web-svc-lb.yaml) для балансировки трафика на под WEB.

Задание:
*Создал [манифест](./dns-svc-lb.yaml) для открытия доступа к CoreDNS (KubeDNS)*

#### Ingress-Nginx

Установлен следующий [манифест](https://raw.githubusercontent.com/kubernetes/ingress-
nginx/master/deploy/static/mandatory.yaml) и добавлена [конфигурация](./ingress/nginx-lb.yaml) для LoadBalance.
Создан [headless сервис](./web-svc-headless.yaml) для пода WEB.  и [Ingress правило](./web-ingress.yaml)

Задание:
*Создал [Ingress правило](./dashboard-ingress.yaml) для доступа к Dashboard*

Создал манифест для [канареечного тестирования](./canary-ingress.yaml)

---
Полезные ссылки:
- [MetalLB Usage](https://metallb.universe.tf/usage/)
- [Ingress Nginx rewrite](https://kubernetes.github.io/ingress-nginx/examples/rewrite/)
- [Canary ingress](https://kubernetes.github.io/ingress-nginx/user-guide/nginx-configuration/annotations/#canary)

Важные заметки:

*Annotation keys and values can only be strings*. Other types, such as boolean or numeric values must be quoted, i.e. "true", "false", "100".

[Annotaions](https://kubernetes.github.io/ingress-nginx/user-guide/nginx-configuration/annotations/)
