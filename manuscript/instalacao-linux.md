# Instalando no GNU/Linux

Será explicado a instalação da forma mais genérica possível, ou seja, dessa forma você poderá instalar as ferramentas em qualquer distribuição GNU/Linux que esteja usando.

### Docker engine no GNU/Linux

Para instalar o docker engine é muito simples. Acesse o seu terminal preferido do GNU/Linux e se torne usuário root:

```
su - root
```
ou no caso da utilização de sudo

```
sudo su - root
```

Agora execute o comando abaixo:

```
wget -qO- https://get.docker.com/ | sh
```
Aconselho fortemente que leia o script que está sendo executado no seu sistema operacional. Acesse [esse link](https://get.docker.com/) e analise o código assim que tiver tempo para fazê-lo.

Esse procedimento demorará um pouco. Após terminar teste executando o comando abaixo:

```
docker run hello-world
```

#### Tratamento de possíveis problemas

Se o acesso a internet da sua máquina passar por um controle de tráfego (aquele que bloqueia o acesso a determinadas páginas) você poderá encontrar problemas no passo do **apt-key**, sendo assim caso passe por esse problema, execute o comando abaixo:

```
wget -qO- https://get.docker.com/gpg | sudo apt-key add -
```

### Docker compose 

Acesse o seu terminal preferido do GNU/Linux e se torne usuário root:

```
su - root
```
ou no caso da utilização de sudo

```
sudo su - root
```

Agora execute o comando abaixo:

```
curl -L https://github.com/docker/compose/releases/download/1.6.2/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
```
Para testar execute o comando abaixo:

```
docker-compose version
```

#### Instalando Docker compose com pip

O [pip](https://en.wikipedia.org/wiki/Pip_(package_manager)) é um gerenciador de pacotes Python, e como o docker-compose é escrito nessa linguagem, é possível instalá-lo desse jeito:

```
pip install docker-compose
```

### Docker machine 

Para instalar o docker engine é muito simples. Acesse o seu terminal preferido do GNU/Linux e se torne usuário root:

```
su - root
```
ou no caso da utilização de sudo

```
sudo su - root
```

Agora execute o comando abaixo:

```
$ curl -L https://github.com/docker/machine/releases/download/v0.7.0/docker-machine-`uname -s`-`uname -m` > /usr/local/bin/docker-machine && \
chmod +x /usr/local/bin/docker-machine
```
Para testar execute o comando abaixo:

```
docker-machine version
```

Obs.: O exemplo anterior utiliza a versão mais recente no momento desta publicação. Verifique se há alguma versão mais atualizada consultando a [documentação oficial](https://docs.docker.com/machine/install-machine/).
