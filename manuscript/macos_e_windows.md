# Como usar Docker sem GNU/Linux

Esse artigo tem como objetivo explicar de forma detalhada, e com exemplos, como funciona o uso de docker em estações MacOS e Windows.

![Docker Toolbox](images/docker_toolbox.png)

Esse texto tem como público alvo pessoas que já sabem um pouco sobre docker, mas ainda não sabiam como o docker pode ser utilizado a partir de uma estação “não linux”.

Como já explicado anteriormente nesse livro, o docker utiliza recursos específicos do kernel hospedeiro  e o GNU/Linux é o único sistema operacional que suporta o docker de forma estável. Isso quer dizer que não é possível iniciar containers docker em uma estação MacOS e Windows, por exemplo.

Não precisa ficar preocupado, caso você não utilize GNU/Linux como sistema operacional, ainda será possível fazer uso dessa tecnologia, sem necessariamente executá-la em seu computador.

Um dos produtos da suíte docker é o [docker toolbox](https://www.docker.com/products/docker-toolbox). Essa solução na verdade é uma abstração para instalação de todo ambiente necessário para fazer uso do docker a partir de uma estação MacOS ou Windows.

Para instalar é muito simples, tanto no Windows, como no MacOS, basta baixar o instalador correspondente nesse [site](https://www.docker.com/products/docker-toolbox) e executá-lo seguindo dos passos descritos nas telas.

Os softwares instalados na sua estação (MacOS ou Windows) a partir do pacote docker toolbox são:

* [Virtualbox](https://www.virtualbox.org/)
* [Docker machine](https://docs.docker.com/machine/overview/)
* [Docker client](https://docs.docker.com/)
* [Docker compose](https://docs.docker.com/compose/overview/)
* [Kitematic](https://docs.docker.com/kitematic/userguide/)

Docker machine é a ferramenta que possibilita criar e manter ambientes docker em máquinas virtuais, ambientes de nuvem e até mesmo em máquina física, mas nesse tópico vamos nos manter apenas em máquina virtual com virtualbox.

Após instalar o docker toolbox, é muito simples criar um ambiente docker com máquina virtual usando o docker machine.

Primeiro vamos verificar se não existem máquinas virtuais com docker instalado em seu ambiente:

```
docker-machine ls
```
O comando acima mostrará apenas ambientes criados e mantidos por seu docker-machine, ou seja, é possível que após instalar seu docker toolbox você não verá máquina alguma criada, sendo assim vamos utilizar o comando abaixo para criar uma máquina:

```
docker-machine create --driver virtualbox default
```

![Arquitetura do Docker toolbox](images/docker_toolbox1.jpg)

O comando acima criou um ambiente que se chama “default”, que na verdade é uma máquina virtual (“Linux VM” que aparece na imagem) criada no virtualbox. Com o comando abaixo será possível visualizar a máquina que acabou de criar:

```
docker-machine ls
```

O retorno será algo parecido com isto:

![](images/resultado_macos_windows.png)

Uma máquina virtual foi criada, dentro dela temos um sistema operacional GNU/Linux com docker host instalado. Esse serviço docker está escutando na porta TCP 2376 do endereço 192.168.99.100. Essa interface utiliza uma rede específica entre seu computador e as máquinas do virtualbox.

Para desligar a máquina virtual basta executar o comando abaixo:

```
docker-machine stop default
```
Para iniciar novamente a máquina, basta executar o comando abaixo:

```
docker-machine start default
```
O comando “start” é responsável apenas por iniciar a máquina, agora é necessário fazer com que os aplicativos de controle do docker, que foram instalados na sua estação, possam se conectar a máquina virtual criada no virtualbox com o comando “docker-machine create”.

Os aplicativos de controle (docker e docker-compose) fazem uso de variáveis de ambiente para configurar qual docker host será utilizado. O comando abaixo facilitará esse trabalho de aplicar todas as variáveis corretamente:

```
docker-machine env default
```

O resultado desse comando no MacOS será:

![](images/resultado_macos_windows2.png)

Como podemos ver, ele informa o que pode ser feito para configurar todas as suas variáveis. Você pode copiar as quatros primeiras linhas, que começam com “export”, e colar no seu terminal ou pegar apenas a última linha sem o “#” no começo e executar na linha de comando:

```
eval $(docker-machine env default)
```

Agora os seus aplicativos de controle (docker e docker-compose) estarão aptos a utilizar o docker host a partir da conexão feita no serviço do ip 192.168.99.100, que na verdade é a máquina criada com o comando “docker-machine create” mencionados anteriormente nesse capítulo.

Para testar vamos listar os containers que temos em execução nesse docker host com o comando abaixo:

```
docker ps
```
O comando acima é executado na linha de comando do MacOS ou Windows e esse cliente do docker se conectará na máquina virtual, que aqui chamamos de “Linux VM”, e solicitará a lista de containers em execução nesse docker host remoto.

Vamos iniciar um container com o comando abaixo:

```
docker run -itd alpine sh
```
Agora vamos verificar novamente a lista de containers em execução:

```
docker ps
```
Agora poderemos ver que o container criado a partir da imagem “alpine” está em execução. Vale salientar que esse processo está sendo executado no docker host, na máquina criada dentro do virtualbox, que aqui nesse exemplo tem o ip 192.168.99.100.

Para verificar o endereço IP da sua máquina, basta executar o comando abaixo

```
docker-machine ip
```
Caso seu container exponha alguma porta para o docker host, seja via parâmetro “-p” do comando “docker run -p porta_host:porta_container” ou via parâmetro “ports” do docker-compose.yml, vale lembrar que o IP que você deve usar para acessar o serviço exposto é endereço IP do docker host, que no nosso exemplo é “192.168.99.100”.

Nesse momento você deve estar se perguntando como é possível mapear uma pasta da sua estação “não-linux” para dentro de um container. Aqui entra um novo artíficio do docker para contornar esse problema.

Toda máquia criada com o driver “virtualbox” automaticamente cria um mapeamento do tipo  “pastas compartilhadas do virtualbox” da sua pasta de usuários para a raiz do docker host.

Para visualizar esse mapeamento vamos acessar a máquina virtual que acabamos de criar nos passos anteriores:

```
docker-machine ssh default
```
No console da máquina GNU/Linux digite os seguintes comandos:

```
sudo su
mount | grep vboxsf
```

O [vboxsf](https://help.ubuntu.com/community/VirtualBox/SharedFolders) é um sistema de arquivo usado pelo virtualbox para montar volumes que são compartilhados da estação que foi usada para instalar o virtualbox, ou seja, utilizando esse recurso de pasta compartilhada é possível montar a pasta /Users do MacOS na pasta /Users da máquina virtual do docker host.

Todo conteúdo existente na sua pasta /Users/SeuUsuario do seu MacOS será acessível na pasta /Users/SeuUsuario da máquina GNU/Linux que atua como docker host nesse exemplo apresentado, ou seja, caso você efetue a montagem da pasta /Users/SeuUsuario/MeuCodigo para dentro do container, o dado a ser montado é o mesmo da sua estação e nada precisa ser feito para replicar esse código para dentro do docker host.

Vamos efetuar um teste. Crie um arquivo dentro da sua pasta de usuário:

```
touch teste
```
Vamos iniciar um container e mapear nossa pasta atual dentro dele:

```
docker run -itd -v "$PWD:/tmp" --name teste alpine sh
```
No comando acima iniciamos um container que será nomeado como “teste” e terá mapeado a pasta atual (a variável PWD indica o endereço atual no MacOS) na pasta /tmp dentro do container.

Vamos verificar se o arquivo que acabamos de criar está dentro do container:

```
docker exec teste ls /tmp/teste
```
A linha acima executou o comando “ls /tmp/teste” dentro do container nomeado de “teste” que foi criado no passo anterior.

Agora acesse o docker host novamente com o comando abaixo, e por fim verificar se o arquivo teste se encontra na pasta de usuário.:

```
docker-machine ssh default
```
**Tudo pode ser feito automaticamente? Claro que sim!**

Agora que você já sabe como fazer tudo manualmente, se precisar instalar o docker toolbox em uma máquina nova e não lembrar quais comandos precisa executar para criar uma máquina nova ou simplesmente aprontar seu ambiente para uso, basta executar o programa “Docker quickstart terminal” e ele fará todo trabalho automaticamente pra ti, ou seja, caso não exista nenhuma máquina criada, ele criará uma chamada “default”, caso a máquina já tenha sido criada, ele automaticamente configura suas variáveis de ambiente e lhe deixar apto pra utilizar o docker host remoto apartir de seus aplicativos de controle (docker e docker-compose).
