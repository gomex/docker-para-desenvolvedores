# Dicas para uso do Docker

Se você leu a primeira parte do livro já sabe o básico sobre Docker, mas agora que pretende começar a usar com mais frequência, alguns desconfortos podem surgir, pois, como qualquer ferramenta, o Docker tem seu próprio conjunto de boas práticas e dicas.

O objetivo desse texto é apresentar algumas dicas para o bom uso do Docker. Isso não quer dizer que, a forma que você executa é, necessariamente, errada.

Toda ferramenta demanda algumas melhores práticas para tornar o uso mais efetivo e com menor possibilidade de problemas futuros.

Esse capítulo foi separado em duas seções: dicas para rodar (`docker container run`) e boas práticas de construção de imagens (`docker build`/`Dockerfile`).

## Dicas para Rodar

Lembre-se, cada comando `docker container run` cria novo contêiner com base em uma imagem específica e inicia um processo dentro dele, a partir de um comando (`CMD` especificado no Dockerfile).

### Contêineres descartáveis

É esperado que os contêineres executados possam ser descartados sem qualquer problema. Sendo assim, é importante utilizar contêineres verdadeiramente efêmeros.

Para tal, utilize o argumento `--rm`. Isso faz com que todos os contêineres, e seus dados, sejam removidos após o termino da execução, evitando consumir disco desnecessariamente.

Em geral, pode-se utilizar o comando `run` como no exemplo:

```sh
docker container run --rm -it debian /bin/bash
```

Note aqui que `-it` significa `--interactive --tty`. É usado para fixar a linha de comando com o contêiner, assim, após esse `docker container run`, todos os comandos são executados pelo `bash` de dentro do contêiner. Para sair use `exit` ou pressione `Control-d`. Esses parâmetros são muito úteis para executar um contêiner em primeiro plano.

### Verifique variáveis de ambiente

Às vezes faz-se necessário verificar quais metadados são definidos como variáveis de ambiente em uma imagem. Use o comando `env` para obter essa informação:

```sh
docker container run --rm -it debian env
```

Para verificar as variáveis de ambientes passados de um contêiner já criado:

```sh
docker inspect --format '{{.Config.Env}}' <container>
```

Para outros metadados, use variações do comando `docker inspect`.

### Logs

Docker captura logs da saída padrão (`STDOUT`) e saída de erros (`STDERR`).

Esses registros podem ser roteados para diferentes sistemas (`syslog`, `fluentd`, ...) que, podem ser especificados através da [configuração de driver](https://docs.docker.com/engine/admin/logging/overview/) `--log-driver=VALUE` no comando `docker container run`.

Quando utilizado o driver padrão `json-file` (e também `journald`), pode-se utilizar o seguinte comando para recuperar os logs:

```sh
docker logs -f <container_name>
```

Observe também o argumento `-f` para acompanhar as próximas mensagens de log de forma interativa. Quando quiser parar, pressione `Ctrl-c` .

### Backup

Dados em contêineres Docker são expostos e compartilhados através de argumentos de volumes utilizados ao criar e iniciar o contêiner. Esses volumes não seguem as regras do [Union File System](https://docs.docker.com/engine/reference/glossary/#union-file-system), pois os dados persistem mesmo quando o contêiner é removido.

Para criar um volume em determinado contêiner, execute da seguinte forma:

```sh
docker container run --rm -v /usr/share/nginx/html --name nginx_teste nginx
```

Com a execução desse contêiner, teremos serviço Nginx que usa o volume criado para persistir seus dados; os dados persistirão mesmo após o contêiner ser removido.

É boa prática de administração de sistema fazer cópias de segurança (backups) periódicas e, para executar essa atividade (extrair dados), use o comando:

```sh
docker container run --rm -v /tmp:/backup --volumes-from nginx-teste busybox tar -cvf /backup/backup_nginx.tar /usr/share/nginx/html
```

Após a execução do comando, temos um arquivo `backup_nginx.tar` dentro da pasta /tmp do **Docker host**.

Para restaurar esse backup utilize:

```sh
docker container run --rm -v /tmp:/backup --volumes-from nginx-teste busybox tar -xvf /backup/backup.tar /usr/share/nginx/html
```

Mais informação também podem ser encontradas [na resposta](https://stackoverflow.com/a/34776997/1046584), onde é possível encontrar alguns *aliases* para esses dois comandos. Esses *aliases* também estão disponíveis abaixo, na seção *Aliases*.

Outras fontes são:

 * Documentação oficial do Docker sobre [Backup, restauração ou migração de dados (em inglês)](https://docs.docker.com/storage/volumes/#backup-restore-or-migrate-data-volumes)

 * Uma ferramenta de backup (atualmente depreciada): [docker-infra/docker-backup](https://github.com/docker-infra/docker-backup)


### Use docker container exec para "entrar em um contêiner"

Eventualmente, é necessário entrar em um contêiner em execução afim de verificar algum problema, efetuar testes ou simplesmente depurar (*debug*).
Nunca instale o daemon SSH em um contêiner Docker. Use `docker container exec` para entrar em um contêiner e rodar comandos:

```sh
docker container exec -it <nome do container em execução> bash
```

A funcionalidade é útil em desenvolvimento local e experimentações. Mas evite utilizar o contêiner em produção ou automatizar ferramentas em volta dele.

Verifique a [documentação](https://docs.docker.com/engine/reference/commandline/exec/).

### Sem espaço em disco do Docker Host

Ao executar contêineres e construir imagens várias vezes, o espaço em disco pode se tornar escasso. Quando isso acontece, é necessário limpar alguns contêineres, imagens e logs.

Uma maneira rápida de limpar contêineres e imagens é utilizar o seguinte comando:

```sh
docker system prune
```

Com esse comando você removerá:

* Todos os contêineres que não estão em uso no momento
* Todos os volumes que não estão em uso por ao menos um contêiner
* Todas as redes que não estão em uso por ao menos um contêiner
* Todas as imagens *dangling*

Obs: Pra não aprofundar muito no conceito baixo nível do Docker, podemos dizer que imagens *dangling* são simplesmente sem ponteiros e assim desnecessárias para o uso convencional.

Dependendo do tipo de aplicação, logs também podem ser volumosos. O gerenciamento depende muito de qual [driver](https://docs.docker.com/engine/admin/logging/overview/) é utilizado. No driver padrão (`json-file`) a limpeza pode se dar através da execução do seguinte comando dentro do **Docker Host**:

```sh
echo "" > $(docker inspect --format='{{.LogPath}}' <container_name_or_id>)
```

- A proposta de funcionalidade de limpar o histórico de logs foi, na verdade, rejeitada. Mais informação: [https://github.com/docker/compose/issues/1083](https://github.com/docker/compose/issues/1083)

- Considere especificar a opção `max-size` para o _driver_ de log ao executar `docker container run`: [https://docs.docker.com/engine/reference/logging/overview/#json-file-options](https://docs.docker.com/engine/reference/logging/overview/#json-file-options)

### Aliases

Com alias é possível transformar comandos grandes em menores. Temos algumas novas opções para executar tarefas mais complexas.

Utilize esses *aliases* no seu `.zshrc` ou `.bashrc` para limpar imagens e contêineres, fazer backup e restauração, etc.

```sh
# runs docker container exec in the latest container
function docker-exec-last {
  docker container exec -ti $( docker ps -a -q -l) /bin/bash
}

function docker-get-ip {
  # Usage: docker-get-ip (name or sha)
  [ -n "$1" ] && docker inspect --format "{{ .NetworkSettings.IPAddress }}" $1
}

function docker-get-id {
  # Usage: docker-get-id (friendly-name)
  [ -n "$1" ] && docker inspect --format "{{ .ID }}" "$1"
}

function docker-get-image {
  # Usage: docker-get-image (friendly-name)
  [ -n "$1" ] && docker inspect --format "{{ .Image }}" "$1"
}

function docker-get-state {
  # Usage: docker-get-state (friendly-name)
  [ -n "$1" ] && docker inspect --format "{{ .State.Running }}" "$1"
}

function docker-memory {
  for line in `docker ps | awk '{print $1}' | grep -v CONTAINER`; do docker ps | grep $line | awk '{printf $NF" "}' && echo $(( `cat /sys/fs/cgroup/memory/docker/$line*/memory.usage_in_bytes` / 1024 / 1024 ))MB ; done
}
# keeps the commmand history when running a container
function basher() {
    if [[ $1 = 'run' ]]
    then
        shift
        docker container run -e HIST_FILE=/root/.bash_history -v $HOME/.bash_history:/root/.bash_history "$@"
    else
        docker "$@"
    fi
}
# backup files from a docker volume into /tmp/backup.tar.gz
function docker-volume-backup-compressed() {
  docker container run --rm -v /tmp:/backup --volumes-from "$1" debian:jessie tar -czvf /backup/backup.tar.gz "${@:2}"
}
# restore files from /tmp/backup.tar.gz into a docker volume
function docker-volume-restore-compressed() {
  docker container run --rm -v /tmp:/backup --volumes-from "$1" debian:jessie tar -xzvf /backup/backup.tar.gz "${@:2}"
  echo "Double checking files..."
  docker container run --rm -v /tmp:/backup --volumes-from "$1" debian:jessie ls -lh "${@:2}"
}
# backup files from a docker volume into /tmp/backup.tar
function docker-volume-backup() {
  docker container run --rm -v /tmp:/backup --volumes-from "$1" busybox tar -cvf /backup/backup.tar "${@:2}"
}
# restore files from /tmp/backup.tar into a docker volume
function docker-volume-restore() {
  docker container run --rm -v /tmp:/backup --volumes-from "$1" busybox tar -xvf /backup/backup.tar "${@:2}"
  echo "Double checking files..."
  docker container run --rm -v /tmp:/backup --volumes-from "$1" busybox ls -lh "${@:2}"
}
```

Fontes:

- [https://zwischenzugs.wordpress.com/2015/06/14/my-favourite-docker-tip/](https://zwischenzugs.wordpress.com/2015/06/14/my-favourite-docker-tip/)
- [https://website-humblec.rhcloud.com/docker-tips-and-tricks/](https://website-humblec.rhcloud.com/docker-tips-and-tricks/)

## Boas práticas para construção de imagens

Em Docker, as imagens são tradicionalmente construídas usando um arquivo `Dockerfile`. Existem alguns bons guias sobre as melhores práticas para construir imagens Docker. Recomendamos dar uma olhada:

- [Documentação oficial](https://docs.docker.com/engine/articles/dockerfile_best-practices/)
- [Guia do projeto Atomic](https://www.projectatomic.io/docs/docker-image-author-guidance/)
- [Melhores práticas do Michael Crosby Parte 1](https://crosbymichael.com/dockerfile-best-practices.html)
- [Melhores práticas do Michael Crosby Parte 2](https://crosbymichael.com/dockerfile-best-practices.html)

### Use um "linter"

*"Linter"* é uma ferramenta que fornece dicas e avisos sobre algum código fonte. Para `Dockerfile` existem opções simples, mas é, ainda, um espaço novo em evolução.

Muitas opções foram discutidas [aqui](https://stackoverflow.com/questions/28182047/is-there-a-way-to-lint-the-dockerfile).

Desde janeiro de 2016, o mais completo parece ser [hadolint](https://hadolint.lukasmartinelli.ch/), disponível em duas versões: on-line e terminal. O interessante dessa ferramenta é que usa o maduro [Shell Check](https://www.shellcheck.net/about.html) para validar os comandos shell.

### O básico

O contêiner produzido pela imagem do `Dockerfile` deve ser o mais efêmero possível. Significa que deve ser possível para-lo, destruí-lo e substituí-lo por um novo contêiner construído com o mínimo de esforço.

É comum colocar outros arquivos, como documentação, no diretório junto ao `Dockerfile`; para melhorar a performance de construção, exclua arquivos e diretórios criando um arquivo [dockerignore](https://docs.docker.com/engine/reference/builder/) no mesmo diretório. Esse arquivo funciona de maneira semelhante ao `.gitignore`. Usá-lo ajuda a minimizar o contexto de construção enviado -completa com a versão correta- docker host a cada `docker build`.

Evite adicionar pacotes e dependências extras não necessárias à aplicação e minimize a complexidade, tamanho da imagem, tempo de construção e superfície de ataque.

Minimize também o número de camadas: sempre que possível agrupe vários comandos. Porém, também leve em conta a volatilidade e manutenção dessas camadas.

Na maioria dos casos, rode apenas um único processo por contêiner. Desacoplar aplicações em vários contêineres facilita a escalabilidade horizontal, reuso e monitoramento dos contêineres.

### Prefira COPY ao invés de ADD


O comando `ADD` existe desde o início do Docker. É versátil e permite truques além de simplesmente copiar arquivos do contexto de construção, o que o torna mágico e difícil de entender. Permite baixar arquivos de urls e, automaticamente, extrair arquivos de formatos conhecidos (tar, gzip, bzip2, etc.).

Por outro lado, `COPY` é um comando mais simples para inserir arquivos e pastas do caminho de construção para dentro da imagem Docker. Assim, favoreça `COPY` a menos que tenha certeza absoluta que `ADD` é necessário. Para mais detalhes veja [aqui](https://labs.ctl.io/dockerfile-add-vs-copy/).

### Execute um "checksum" depois de baixar e antes de usar o arquivo

Em vez de usar `ADD` para baixar e adicionar arquivos à imagem, favoreça a utilização de [curl](https://curl.haxx.se/) e a verificação através de um `checksum` após o download. Isso garante que o arquivo é o esperado e não poderá variar ao longo do tempo. Se o arquivo que a URL aponta mudar, o `checksum` irá mudar e a construção da imagem falhará. Isso é importante, pois, favorece a reproducibilidade e a segurança na construção de imagens.

Bom exemplo para inspiração é o [Dockerfile oficial do Jenkins](https://github.com/jenkinsci/docker/blob/83ce6f6070f1670563a00d0f61d04edd62b78f4f/Dockerfile#L36):

```
ENV JENKINS_VERSION 1.625.3
ENV JENKINS_SHA 537d910f541c25a23499b222ccd37ca25e074a0c

RUN curl -fL http://mirrors.jenkins-ci.org/war-stable/$JENKINS_VERSION/jenkins.war -o /usr/share/jenkins/jenkins.war \
  && echo "$JENKINS_SHA /usr/share/jenkins/jenkins.war" | sha1sum -c -
```

### Use uma imagem de base mínima

Sempre que possível, utilize imagens oficiais como base para sua imagem. Você pode usar a imagem [`debian`](https://hub.docker.com/_/debian/), por exemplo, que é muito bem controlada e mantida mínima (por volta de 150 mb). Lembre-se também usar *tags* específicas, por exemplo, `debian:jessie`.

Se mais ferramentas e dependências são necessárias, olhe por imagens como [`buildpack-deps`](https://hub.docker.com/_/buildpack-deps/).

Porém, caso `debian` ainda seja muito grande, existem imagens minimalistas como [`alpine`](https://hub.docker.com/r/gliderlabs/alpine/) ou mesmo [`busybox`](https://hub.docker.com/_/busybox). Evite `alpine` se DNS é necessário, existem [alguns problemas a serem resolvidos](https://github.com/gliderlabs/docker-alpine/blob/master/docs/caveats.md). Além disso, evite-o para linguagens que usam o GCC, como Ruby, Node, Python, etc, isso é porque `alpine` utiliza libc MUSL que pode produzir binários diferentes.

Evite imagens gigantes como [`phusion/baseimage`](https://hub.docker.com/r/phusion/baseimage/). Essa imagem é muito grande, foge da filosofia de processo por contêiner e muito do que a compõe não é essencial para contêineres Docker, [veja mais aqui](https://blog.docker.com/2014/06/why-you-dont-need-to-run-sshd-in-docker/) .

[Outras fontes](https://www.iron.io/microcontainers-tiny-portable-containers/)

### Use o cache de construção de camadas

Outra funcionalidade útil que o uso de `Dockerfile` proporciona é a reconstrução rápida usando o cache de camadas. A fim de aproveitar o recurso, insira ferramentas e dependências que mudem com menos frequência no topo do `Dockerfile`.

Por exemplo, considere instalar as dependências de código antes de adicionar o código. No caso de NodeJS:

```
COPY package.json /app/
RUN npm install
COPY . /app
```

Para ler mais sobre isso, veja esse [link](https://bitjudo.com/blog/2014/03/13/building-efficient-dockerfiles-node-dot-js/).

### Limpe na mesma camada

Ao usar um gerenciador de pacotes para instalar algum software, é uma boa prática limpar o cache gerado pelo gerenciador de pacotes logo após a instalação das dependências. Por exemplo, ao usar `apt-get`:

```
RUN apt-get update && \
    apt-get install -y curl python-pip && \
    pip install requests && \
    apt-get remove -y python-pip curl && \
    rm -rf /var/lib/apt/lists/*
```

Em geral, deve-se limpar o cache do apt (gerado por `apt-get update`) através da remoção de `/var/lib/apt/lists`. Isso ajuda a manter reduzido o tamanho da imagem. Além disso, observe que, `pip` e `curl` também são removidos uma vez que são desnecessários para a aplicação de produção. Lembre-se que a limpeza precisa ser feita na mesma camada (comando `RUN`). Caso contrário, os dados serão persistidos nessa camada e removê-los mais tarde não terá efeito no tamanho da imagem final.

Note que, segundo a [documentação](https://github.com/docker/docker/blob/03e2923e42446dbb830c654d0eec323a0b4ef02a/contrib/mkimage/debootstrap#L82-L105), as imagens oficiais de Debian e Ubuntu rodam automaticamente `apt-get clean`. Logo, a invocação explícita não é necessária.

Evite rodar `apt-get upgrade` ou `dist-upgrade`, pois, vários pacotes da imagem base não vão atualizar dentro de um contêiner desprovido de privilégios. Se há um pacote específico a ser atualizado, simplesmete use `apt-get install -y foo` para atualizá-lo automaticamente.

Para ler mais sobre o assunto, veja o [link](https://blog.replicated.com/2016/02/05/refactoring-a-dockerfile-for-image-size/) e esse [outro](https://docs.docker.com/engine/userguide/eng-image/dockerfile_best-practices/#apt-get).

### Use um script "wrapper" como ENTRYPOINT, às vezes


Um *script wrapper* pode ajudar ao tomar a configuração do ambiente e definir a configuração do aplicativo. Pode, até mesmo, definir configurações padrões quando não estão disponíveis.

Ótimo exemplo é o fornecido no artigo de [Kelsey Hightower: 12 Fracturated Apps](https://medium.com/@kelseyhightower/12-fractured-apps-1080c73d481c#.xn2cylwnk):

```sh
#!/bin/sh
set -e
datadir=${APP_DATADIR:="/var/lib/data"}
host=${APP_HOST:="127.0.0.1"}
port=${APP_PORT:="3306"}
username=${APP_USERNAME:=""}
password=${APP_PASSWORD:=""}
database=${APP_DATABASE:=""}
cat <<EOF > /etc/config.json
{
  "datadir": "${datadir}",
  "host": "${host}",
  "port": "${port}",
  "username": "${username}",
  "password": "${password}",
  "database": "${database}"
}
EOF
mkdir -p ${APP_DATADIR}
exec "/app"
```

Note, **sempre** use `exec` em scripts shell que envolvem a aplicação. Desta forma, a aplicação pode receber sinais Unix.

Considere também usar um sistema de inicialização simples (e.g. [dumb init](https://github.com/Yelp/dumb-init)) como a `CMD` base, assim, os sinais do Unix podem ser devidamente tratados. Leia mais [aqui](https://engineeringblog.yelp.com/2016/01/dumb-init-an-init-for-docker.html).

#### Log para stdout

Aplicações dentro de Docker devem emitir logs para `stdout`. Porém, algumas aplicações escrevem os logs em arquivos. Nestes casos, a solução é criar um *symlink* do arquivo para `stdout`.

Exemplo: Dockerfile do [nginx](https://github.com/nginxinc/docker-nginx/blob/master/Dockerfile):

~~~
# forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log
RUN ln -sf /dev/stderr /var/log/nginx/error.log
~~~

Para ler mais, veja esse [link](https://serverfault.com/questions/599103/make-a-docker-application-write-to-stdout).

### Cuidado ao adicionar dados em um volume no Dockerfile

Lembre-se de usar a instrução `VOLUME` para expor dados de bancos de dados, configuração ou arquivos e pastas criados pelo contêiner. Use para qualquer dado mutável e partes servidas ao usuário do serviço para qual a imagem foi criada.

Evite adicionar muitos dados em uma pasta e, em seguida, transformá-lo em `VOLUME` apenas na inicialização do contêiner, pois, nesse momento, pode tornar o carregamento mais lento. Ao criar contêiner, os dados serão copiados da imagem para o volume montado. Como dito antes, use `VOLUME` na criação da imagem.

Além disso, ainda em tempo de criação da imagem (`build`), não adicione dados para caminhos previamente declarados como `VOLUME`. Isso não funciona, os dados não serão persistidos, pois, dados em volumes não são *comitados* em imagens.

Leia mais na [explicação de Jérôme Petazzoni](https://jpetazzo.github.io/2015/01/19/dockerfile-and-data-in-volumes/).

### EXPOSE de portas

O Docker favorece reproducibilidade e portabilidade. Imagens devem ser capazes de rodar em qualquer servidor e quantas vezes forem necessárias. Dessa forma, nunca exponha portas públicas. Porém, exponha, de maneira privada, as portas padrões da aplicação.

```
# mapeamento público e privado, evite
EXPOSE 80:8080

# apenas privado
EXPOSE 80
```
