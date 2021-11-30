-----------------------------------------------------------------------------------------------------------------------------------------------------------
### Создание процесса непрерывной поставки для приложения с применением практик CI/CD и быстрой обратной связью
-----------------------------------------------------------------------------------------------------------------------------------------------------------
#### Итоговый проект курса [DevOps практики и инструменты](https://otus.ru/lessons/devops-praktiki-i-instrumenty/) группы Otus-DevOps-2021-05
-----------------------------------------------------------------------------------------------------------------------------------------------------------
#### О приложении:
- Дано:
    - простое микросервисное приложение:
        - [Crawler](https://github.com/express42/search_engine_crawler)
        - [UI](https://github.com/express42/search_engine_ui)
    - база данных (MongoDB)
    - менеджер очередей сообщений (RabbitMQ)
    - [пример сайта для парсинга](https://vitkhab.github.io/search_engine_test_site/)
- Приложение включает:
    - метрики
    - логи
    - unit-тесты
-----------------------------------------------------------------------------------------------------------------------------------------------------------
#### Требования к проекту:
- Автоматизированные процессы создания и управления платформой:
    - Ресурсы Ya.cloud
    - Инфраструктура для CI/CD
    - Инфраструктура для сбора обратной связи
- Использование практики IaC (Infrastructure as Code) для управления конфигурацией и инфраструктурой
- Настроен процесс CI/CD
- Все, что имеет отношение к проекту хранится в Git
- Настроен процесс сбора обратной связи:
    - Мониторинг (сбор метрик, алертинг, визуализация)
    - Логирование (опционально)
    - Трейсинг (опционально)
    - ChatOps (опционально)
- Документация:
    - README по работе с репозиторием:
        - Описание приложения и его архитектуры
        - How to start?
        - ScreenCast
    - CHANGELOG с описанием выполненной работы
        - Если работа в группе, то пункт включает автора изменений
-----------------------------------------------------------------------------------------------------------------------------------------------------------
#### Каталоги проекта:
1. Каталог src - содержит код приложений crawler и ui. В каждом есть Dockerfile и docker_build.sh для создания контейнера с приложеним.
Собрать и сохранить контейнеры в Docker Hub можно так:
```
$ export USER_NAME=docker_hub_name
$ docker login
$ cd src/crawler && bash docker_build.sh && docker push $USER_NAME/search_engine_crawler:latest
$ cd ../ui && bash docker_build.sh && docker push $USER_NAME/search_engine_ui:latest
```
2. Каталог docker - содержит docker-compose.yml для развертывания приложения и docker-compose-gitlab.yml для развертывания gitlab (например на docker-machine), а также примеры .env-файлов с необходимми переменными.
3. Каталог terraform - содержит файлы main.tf для разворачивания docker-machine и kuber cluster в yandex cloud и вспомогательные файлы с примерами необходимых переменных и т.д.
-----------------------------------------------------------------------------------------------------------------------------------------------------------
Как развернуть MVP:
1. Поднимаем docker-machine для gitlab:
```
cd terraform/docker-machine
cp terraform.tfvars.example terraform.tfvars
vi terraform.tfvars - добавить значения переменных для своего yandex cloud. image_id - уже установлен и это Ubuntu 18.04. По vm_name будем подключать docker-machine. Пусть vm_name="yc-gitlab"
rm -rf terraform.tfstate - при наличии удалить, чтобы развернуть новую машину
terraform plan
terraform apply
```

2. Разворачиваем gitlab:
```
eval $(docker-machine env yc-gitlab)
cd docker
cp .env.gitlab.example .env.gitlab
vi .env.gitlab - добавить "белый" IP машины, которую развернули ранее
docker-compose -f docker-compose-gitlab.yml up -d
docker exec -it gitlab_web_1 cat /etc/gitlab/initial_root_password | grep Password:
С этим временным паролем и логином root заходим в GitLab http://<GITLAB_IP>, меняем пароль root, создаем группу OTUS и проект OTUS_project
git remote add gitlab http://<GITLAB_IP>/otus/otus_project.git
git push gitlab
```

3. Поднимаем gitlab ssh runner (на нем будут собираться контейнеы, подниматься приложение и проводиться unittest-ы):
```
Поднимаем docker-machine для gitlab ssh runner как описано в пункте 1. Пусть vm_name="yc-gitlab-runner". Далее подключим эту машину к GitLab как SSH Runner:
eval $(docker-machine env yc-gitlab-runner)
docker-machine ssh yc-gitlab-runner
sudo echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config
sudo echo "PermitRootLogin yes" >> /etc/ssh/sshd_config
sudo passwd
sudo systemctl restart sshd.service
sudo apt update && apt -y install gitlab-runner docker-compose
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo gitlab-runner register \
 --url http://<GITLAB_IP>/ \
 --non-interactive \
 --executor ssh \
 --ssh-host <RUNNER_IP> \
 --locked=false \
 --name SSHrunner \
 --ssh-user root \
 --ssh-password 'ROOT_PASSWORD' \
 --ssh-disable-strict-host-key-checking=true \
 --registration-token GITLAB_TOKEN
После этого runner можно увидеть здесь: http://<GITLAB_IP>/admin/runners
```

4. После того как отработает .gitlab-ci.yml приложение будет доступно на IP GitLab runner (у меня это 84.252.129.28):
UI: http://84.252.129.28:8000/
RabbitMQ: http://84.252.129.28:15672/
Метрики: http://84.252.129.28:8000/metrics

5. Поднимаем kuber cluster в yandex cloud (для приложения):
```
cd terraform/yandex-kuber
cp terraform.tfvars.example terraform.tfvars
vi terraform.tfvars - добавить значения переменных для своего yandex cloud
rm -rf terraform.tfstate - при наличии удалить, чтобы развернуть новый
terraform plan
terraform apply
```
-----------------------------------------------------------------------------------------------------------------------------------------------------------
