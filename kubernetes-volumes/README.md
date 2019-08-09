# Volumes, Storages, Statefull-приложения в Kubernetes #

## Что сделано:

1. Развернут кластер с помощью [kind](https://kind.sigs.k8s.io/docs/user/quick-start#installation)
2. Установлена StatefulSet [конфигурация](https://raw.githubusercontent.com/express42/otus-platform-snippets/master/Module-02/Kuberenetes-volumes/minio-statefulset.yaml)
3. Добавлен [Headless Service](https://raw.githubusercontent.com/express42/otus-platform-snippets/master/Module-02/Kuberenetes-volumes/minio-headless-service.yaml)
4. Создан Secret и переконфигурирован StatefulSet на его использование

