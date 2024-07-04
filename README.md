# Дипломный практикум в Yandex.Cloud
* [Цели:](#цели)
* [Этапы выполнения:](#этапы-выполнения)
    * [Создание облачной инфраструктуры](#создание-облачной-инфраструктуры)
    * [Создание Kubernetes кластера](#создание-kubernetes-кластера)
    * [Создание тестового приложения](#создание-тестового-приложения)
    * [Подготовка cистемы мониторинга и деплой приложения](#подготовка-cистемы-мониторинга-и-деплой-приложения)
    * [Установка и настройка CI/CD](#установка-и-настройка-cicd)
* [Что необходимо для сдачи задания?](#что-необходимо-для-сдачи-задания)
* [Как правильно задавать вопросы дипломному руководителю?](#как-правильно-задавать-вопросы-дипломному-руководителю)

**Перед началом работы над дипломным заданием изучите [Инструкция по экономии облачных ресурсов](https://github.com/netology-code/devops-materials/blob/master/cloudwork.MD).**

---
## Цели:

1. Подготовить облачную инфраструктуру на базе облачного провайдера Яндекс.Облако.
2. Запустить и сконфигурировать Kubernetes кластер.
3. Установить и настроить систему мониторинга.
4. Настроить и автоматизировать сборку тестового приложения с использованием Docker-контейнеров.
5. Настроить CI для автоматической сборки и тестирования.
6. Настроить CD для автоматического развёртывания приложения.

---
## Этапы выполнения:


### Создание облачной инфраструктуры

Для начала необходимо подготовить облачную инфраструктуру в ЯО при помощи [Terraform](https://www.terraform.io/).

Особенности выполнения:

- Бюджет купона ограничен, что следует иметь в виду при проектировании инфраструктуры и использовании ресурсов;
  Для облачного k8s используйте региональный мастер(неотказоустойчивый). Для self-hosted k8s минимизируйте ресурсы ВМ и долю ЦПУ. В обоих вариантах используйте прерываемые ВМ для worker nodes.

Предварительная подготовка к установке и запуску Kubernetes кластера.

1. Создайте сервисный аккаунт, который будет в дальнейшем использоваться Terraform для работы с инфраструктурой с необходимыми и достаточными правами. Не стоит использовать права суперпользователя
2. Подготовьте [backend](https://www.terraform.io/docs/language/settings/backends/index.html) для Terraform:  
   а. Рекомендуемый вариант: S3 bucket в созданном ЯО аккаунте(создание бакета через TF)
   б. Альтернативный вариант:  [Terraform Cloud](https://app.terraform.io/)
3. Создайте VPC с подсетями в разных зонах доступности.
4. Убедитесь, что теперь вы можете выполнить команды `terraform destroy` и `terraform apply` без дополнительных ручных действий.
5. В случае использования [Terraform Cloud](https://app.terraform.io/) в качестве [backend](https://www.terraform.io/docs/language/settings/backends/index.html) убедитесь, что применение изменений успешно проходит, используя web-интерфейс Terraform cloud.

Ожидаемые результаты:

1. Terraform сконфигурирован и создание инфраструктуры посредством Terraform возможно без дополнительных ручных действий.
2. Полученная конфигурация инфраструктуры является предварительной, поэтому в ходе дальнейшего выполнения задания возможны изменения.

> Чувствительные данные `token`, `folder_id`, `cloud_id` лежат в файле `personal.auto.tfvars`, который не пушится в Git репозиторий  

#### Результат:
```bash
Apply complete! Resources: 12 added, 0 changed, 0 destroyed.

Outputs:

external_ip_address_nodes = {
  "node0" = "158.160.44.225"
  "node1" = "158.160.94.252"
  "node2" = "158.160.59.223"
}
internal_ip_address_nodes = {
  "node0" = "10.10.1.25"
  "node1" = "10.10.2.28"
  "node2" = "10.10.3.32"
}
```
---
### Создание Kubernetes кластера

На этом этапе необходимо создать [Kubernetes](https://kubernetes.io/ru/docs/concepts/overview/what-is-kubernetes/) кластер на базе предварительно созданной инфраструктуры.   Требуется обеспечить доступ к ресурсам из Интернета.

Это можно сделать двумя способами:

1. Рекомендуемый вариант: самостоятельная установка Kubernetes кластера.  
   а. При помощи Terraform подготовить как минимум 3 виртуальных машины Compute Cloud для создания Kubernetes-кластера. Тип виртуальной машины следует выбрать самостоятельно с учётом требовании к производительности и стоимости. Если в дальнейшем поймете, что необходимо сменить тип инстанса, используйте Terraform для внесения изменений.  
   б. Подготовить [ansible](https://www.ansible.com/) конфигурации, можно воспользоваться, например [Kubespray](https://kubernetes.io/docs/setup/production-environment/tools/kubespray/)  
   в. Задеплоить Kubernetes на подготовленные ранее инстансы, в случае нехватки каких-либо ресурсов вы всегда можете создать их при помощи Terraform.
2. Альтернативный вариант: воспользуйтесь сервисом [Yandex Managed Service for Kubernetes](https://cloud.yandex.ru/services/managed-kubernetes)  
   а. С помощью terraform resource для [kubernetes](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/kubernetes_cluster) создать **региональный** мастер kubernetes с размещением нод в разных 3 подсетях      
   б. С помощью terraform resource для [kubernetes node group](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/kubernetes_node_group)

Ожидаемый результат:

1. Работоспособный Kubernetes кластер.
2. В файле `~/.kube/config` находятся данные для доступа к кластеру.
3. Команда `kubectl get pods --all-namespaces` отрабатывает без ошибок.

> Для того, чтобы запустить выполнение playbook'а необходимо в файлах `inventory.ini` и `k8s-cluster.yml` изменить строки
```inventory.ini
[all]
node0 ansible_host=158.160.44.225          ip=10.10.1.25 #указываем внешний и внутренний ip ноды
node1 ansible_host=158.160.94.252          ip=10.10.2.28 #указываем внешний и внутренний ip ноды
node2 ansible_host=158.160.59.223          ip=10.10.3.32 #указываем внешний и внутренний ip ноды
```
```k8s-cluster.yml
# Make a copy of kubeconfig on the host that runs Ansible in {{ inventory_dir }}/artifacts
kubeconfig_localhost: true #ставим `true`, чтобы `kubeconfig` был создан на хосте как артефакт

# Supplementary addresses that can be added in kubernetes ssl keys.
# That can be useful for example to setup a keepalived virtual IP
supplementary_addresses_in_ssl_keys: [158.160.44.225, 10.10.1.25] #указываем внешний и внутренний ip `node0`, чтобы был доступ до кластера по внешнему адресу
```

#### Результат:
```bash
mav@mav-pc:~/work/Diplom/prod$ kubectl get pods --all-namespaces
NAMESPACE     NAME                                       READY   STATUS    RESTARTS   AGE
kube-system   calico-kube-controllers-68485cbf9c-5snvx   1/1     Running   0          29m
kube-system   calico-node-gchg8                          1/1     Running   0          30m
kube-system   calico-node-jczgw                          1/1     Running   0          30m
kube-system   calico-node-z9spq                          1/1     Running   0          30m
kube-system   coredns-69db55dd76-7lnzg                   1/1     Running   0          28m
kube-system   coredns-69db55dd76-gzr26                   1/1     Running   0          28m
kube-system   dns-autoscaler-6f4b597d8c-v9r55            1/1     Running   0          28m
kube-system   kube-apiserver-node0                       1/1     Running   1          34m
kube-system   kube-controller-manager-node0              1/1     Running   3          34m
kube-system   kube-proxy-cfw7m                           1/1     Running   0          32m
kube-system   kube-proxy-j25d5                           1/1     Running   0          32m
kube-system   kube-proxy-tmfmr                           1/1     Running   0          32m
kube-system   kube-scheduler-node0                       1/1     Running   2          34m
kube-system   nginx-proxy-node1                          1/1     Running   0          32m
kube-system   nginx-proxy-node2                          1/1     Running   0          32m
kube-system   nodelocaldns-pn552                         1/1     Running   0          28m
kube-system   nodelocaldns-q7kgp                         1/1     Running   0          28m
kube-system   nodelocaldns-xjj4m                         1/1     Running   0          28m
```
---
### Создание тестового приложения

Для перехода к следующему этапу необходимо подготовить тестовое приложение, эмулирующее основное приложение разрабатываемое вашей компанией.

Способ подготовки:

1. Рекомендуемый вариант:  
   а. Создайте отдельный git репозиторий с простым nginx конфигом, который будет отдавать статические данные.  
   б. Подготовьте Dockerfile для создания образа приложения.
2. Альтернативный вариант:  
   а. Используйте любой другой код, главное, чтобы был самостоятельно создан Dockerfile.

Ожидаемый результат:

1. Git репозиторий с тестовым приложением и Dockerfile.
2. Регистри с собранным docker image. В качестве регистри может быть DockerHub или [Yandex Container Registry](https://cloud.yandex.ru/services/container-registry), созданный также с помощью terraform.

#### Результат:   
> [Git репозиторий](https://github.com/AVasMakarov/MyApp) с тестовым приложением, которое собирается и пушится в регистри   
> [DockerHub регистри](https://hub.docker.com/r/avasmakarov/myapp/tags) с образом собранного приложения, который деплоится в кластер  

---
### Подготовка cистемы мониторинга и деплой приложения

Уже должны быть готовы конфигурации для автоматического создания облачной инфраструктуры и поднятия Kubernetes кластера.  
Теперь необходимо подготовить конфигурационные файлы для настройки нашего Kubernetes кластера.

Цель:
1. Задеплоить в кластер [prometheus](https://prometheus.io/), [grafana](https://grafana.com/), [alertmanager](https://github.com/prometheus/alertmanager), [экспортер](https://github.com/prometheus/node_exporter) основных метрик Kubernetes.
2. Задеплоить тестовое приложение, например, [nginx](https://www.nginx.com/) сервер отдающий статическую страницу.

Способ выполнения:
1. Воспользовать пакетом [kube-prometheus](https://github.com/prometheus-operator/kube-prometheus), который уже включает в себя [Kubernetes оператор](https://operatorhub.io/) для [grafana](https://grafana.com/), [prometheus](https://prometheus.io/), [alertmanager](https://github.com/prometheus/alertmanager) и [node_exporter](https://github.com/prometheus/node_exporter). При желании можете собрать все эти приложения отдельно.
2. Для организации конфигурации использовать [qbec](https://qbec.io/), основанный на [jsonnet](https://jsonnet.org/). Обратите внимание на имеющиеся функции для интеграции helm конфигов и [helm charts](https://helm.sh/)
3. Если на первом этапе вы не воспользовались [Terraform Cloud](https://app.terraform.io/), то задеплойте и настройте в кластере [atlantis](https://www.runatlantis.io/) для отслеживания изменений инфраструктуры. Альтернативный вариант 3 задания: вместо Terraform Cloud или atlantis настройте на автоматический запуск и применение конфигурации terraform из вашего git-репозитория в выбранной вами CI-CD системе при любом комите в main ветку. Предоставьте скриншоты работы пайплайна из CI/CD системы.

Ожидаемый результат:
1. Git репозиторий с конфигурационными файлами для настройки Kubernetes.
2. Http доступ к web интерфейсу grafana.
3. Дашборды в grafana отображающие состояние Kubernetes кластера.
4. Http доступ к тестовому приложению.

> Для установки стека `prometheus` необходимо выполнить следующую команду
```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts && \
helm repo update && \
helm upgrade --install stable prometheus-community/kube-prometheus-stack --namespace monitoring --create-namespace
```
> Чтобы подключаться к серверу извне перенастроим сервисы(svc) созданные для `kube-prometheus-stack`.  
> По умолчанию используется ClusterIP. Для того чтобы подключиться извне у сервисов меняем тип порта на `NodePort` добавляем значение `nodePort: 30000` (выбираем любое из диапазона 30000-32767)  
> Для этого выполняем команды  
> - `kubectl edit svc stable-kube-prometheus-sta-prometheus -n monitoring` и вносим изменения,  
> - `kubectl edit svc stable-grafana -n monitoring` и вносим изменения  
> 
> `Логин/пароль` для доступа к вэб-интерфейсу: `admin/prom-operator`
#### Результат:  
> [Git репозиторий](https://github.com/AVasMakarov/Diplom) с конфигурационными файлами для развертывания Kubernetes  

##### Дашборды в grafana
![Дашборды в grafana](https://github.com/AVasMakarov/Diplom/blob/master/Screenshots/1.png?raw=true)

##### Http доступ к тестовому приложению
![Http доступ к тестовому приложению](https://github.com/AVasMakarov/Diplom/blob/master/Screenshots/2.png?raw=true)
---
### Установка и настройка CI/CD

Осталось настроить ci/cd систему для автоматической сборки docker image и деплоя приложения при изменении кода.

Цель:

1. Автоматическая сборка docker образа при коммите в репозиторий с тестовым приложением.
2. Автоматический деплой нового docker образа.

Можно использовать [teamcity](https://www.jetbrains.com/ru-ru/teamcity/), [jenkins](https://www.jenkins.io/), [GitLab CI](https://about.gitlab.com/stages-devops-lifecycle/continuous-integration/) или GitHub Actions.

Ожидаемый результат:

1. Интерфейс ci/cd сервиса доступен по http.
2. При любом коммите в репозиторие с тестовым приложением происходит сборка и отправка в регистр Docker образа.
3. При создании тега (например, v1.0.0) происходит сборка и отправка с соответствующим label в регистри, а также деплой соответствующего Docker образа в кластер Kubernetes.

> Для автоматической сборки и пуша был выбран `GitHub Actions` и для деплоя в кластер `werf`.  
> В секреты были добавлены  
> - `DOCKER_USERNAME` #логин с DockerHub,  
> - `DOCKER_PASSWORD` #API ключ созданный в ЛК DockerHub для подключения,  
> - `KUBE_CONFIG_BASE64_DATA` #создается выполнением команды `cat ~/.kube/config | base64` получится набор из букв, цифр и символов, которые вставляем в секрет

#### Результат:
```bash
git add -A && git commit -am "run CI/CD with tag=v1.1.0" && git tag -af v1.1.0 -m "my version app v1.1.0" && \
git push -u origin v1.1.0
```
##### Интерфейс ci/cd сервиса
![Интерфейс ci/cd сервиса доступен по http](https://github.com/AVasMakarov/Diplom/blob/master/Screenshots/3.png?raw=true)

##### Сборка и отправка образа
![Сборка и отправка образа с соответствующим label в регистри](https://github.com/AVasMakarov/Diplom/blob/master/Screenshots/4.png?raw=true)
---
## Что необходимо для сдачи задания?

1. Репозиторий с конфигурационными файлами Terraform и готовность продемонстрировать создание всех ресурсов с нуля.
2. Пример pull request с комментариями созданными atlantis'ом или снимки экрана из Terraform Cloud или вашего CI-CD-terraform pipeline.
3. Репозиторий с конфигурацией ansible, если был выбран способ создания Kubernetes кластера при помощи ansible.
4. Репозиторий с Dockerfile тестового приложения и ссылка на собранный docker image.
5. Репозиторий с конфигурацией Kubernetes кластера.
6. Ссылка на тестовое приложение и веб интерфейс Grafana с данными доступа.
7. Все репозитории рекомендуется хранить на одном ресурсе (github, gitlab)

## Доработка 04.07.2024

> Внес следующие изменения в проект:
> - изменения в docker-publish.yml, теперь образ собирается только при пуше с тэгом
> - в myapp-deploment.yaml указал имя образа для деплоя в кластер
> - удалил строки из werf.yml, теперь werf не пересобирает образ, а берет собранный из Docker Hub с тэгом

> docker-publish.yaml
```yaml
...
push:
  #    branches: [ "master" ] # закомментировал чтобы образ собирался только при пуше с тэгом
  tags: [ 'v*.*.*' ]
#  pull_request:            # закомментировал чтобы образ собирался только при пуше с тэгом
#    branches: [ "master" ] # закомментировал чтобы образ собирался только при пуше с тэгом
...
...
- name: Converge
  uses: werf/actions/converge@v2
  env:
    WERF_SET_STRING_IMAGE: image="${{ secrets.DOCKER_USERNAME }}/${{ env.IMAGE_NAME }}:${{ steps.meta.outputs.version }}" #переменная с именем образа
  with:
    kube-config-base64-data: ${{ secrets.KUBE_CONFIG_BASE64_DATA }}
...
```

> myapp-deployment.yaml
```yaml
...
spec:
  containers:
    - name: app-web
      image: {{ $.Values.image }} #переменная с именем образа
  terminationGracePeriodSeconds: 30
...
```
