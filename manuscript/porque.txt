# Por que usar Docker?

Docker tem sido um assunto bem comentado ultimamente, muitos artigos foram escrito geralmente tratando sobre como usá-lo, ferramentas auxiliares, integrações e afins, mas muitas pessoas ainda se fazem a questão mais básica quando se trata da possibilidade de utilizar qualquer nova tecnologia: “Por que devo usar isso?” ou seria “O que isso tem a me oferecer diferente do que já tenho hoje?”

![](images/docker_porque.jpg)

É normal que ainda duvidem do potencial do Docker, alguns até acham que se trata de um [hype](http://techfree.com.br/2015/06/sera-que-esse-modelo-de-containers-e-um-hype/), mas nesse capítulo pretendo demonstrar alguns bons motivos para se utilizar Docker.


Vale a pena frisar que o Docker não é uma “bala de prata”, ou seja, ele não se propõe a resolver todos problemas, muito menos ser a solução única para as mais variadas situações.

Segue abaixo alguns bons motivos para se utilizar Docker:

### 1 – Ambientes semelhantes

Uma vez que sua aplicação seja transformada em uma imagem Docker, ela pode ser instanciada como container em qualquer ambiente que desejar, ou seja, isso significa que você poderá utilizar a sua aplicação no notebook do desenvolvedor da mesma forma que ela seria executada no servidor de produção.

A imagem Docker aceita parâmetros durante o inicio do container, isso indica que uma mesma imagem pode se comportar de formas diferentes entre os distintos ambientes, ou seja, esse container pode conectar a seu banco de dados local para testes, usando as credenciais e base de dados de teste, mas quanto o container, criado a partir da mesma imagem, receber parâmetros do ambiente de produção ele acessará a base de dados em uma infraestrutura mais robusta, com suas respectivas credenciais e base de dados de produção, por exemplo.

As imagens Docker podem ser consideradas como implantações atômicas, ou seja, isso é o que proporciona maior previsibilidade comparado outras ferramentas como Puppet, Chef, Ansible, etc. Impactando positivamente na analise de erros, assim como na confiabilidade do processo de [entrega contínua](https://www.thoughtworks.com/continuous-delivery), que se baseia fortemente na criação de um único artefato que migra entre ambientes. No caso do Docker o artefato seria a própria imagem com todas as dependências requeridas para executar o seu código, seja ele compilado ou dinâmico.

### 2 – Aplicação como pacote completo

Utilizando as imagens Docker é possível empacotar toda sua aplicação e suas dependências, dessa forma facilitando sua distribuição, pois não será mais necessário enviar uma extensa documentação explicando como configurar a infraestrutura necessária para permitir sua execução, basta disponibilizar a imagem em um repositório e liberar o acesso para o usuário da mesma e ele baixará o pacote, que será executado sem nenhum problema.

A atualização também é positivamente afetada, pois a [estrutura de camadas](http://techfree.com.br/2015/12/entendendo-armazenamentos-de-dados-no-docker/) do Docker viabiliza que em caso de mudança, apenas a parte modificada seja transferida e assim o ambiente pode ser alterado de forma mais rápida e simples. O usuário só precisaria executar apenas um comando para atualizar sua imagem da aplicação, que seria refletida no container em execução apenas no momento desejado. As imagens Docker podem utilizar tags e assim viabilizar o armazenamento de múltiplas versões da mesma aplicação, isso quer dizer que em caso de problema na atualização, o plano de retorno seria basicamente utilizar a imagem com a tag anterior.

### 3 – Padronização e replicação

Como as imagens Docker são construídas através de [arquivos de definição](https://docs.docker.com/engine/reference/builder/), é possível garantir que um determinado padrão seja seguido e assim aumentar confiança em sua replicação, ou seja, basta que as imagens sigam as [melhores práticas](https://docs.docker.com/engine/userguide/eng-image/dockerfile_best-practices/) de construção para que seja viável [escalarmos](https://pt.wikipedia.org/wiki/Escalabilidade) a nossa estrutura rapidamente.

Caso a equipe receba um nova pessoa para trabalhar no desenvolvimento, essa poderá receber o ambiente de trabalho em alguns comandos. Esse processo durará o tempo do download das imagens a se utilizar, assim como os arquivos de definições da orquestração das mesmas, ou seja, isso quer dizer que no início de uma nova pessoa no processo de desenvolvimento da aplicação ela poderá reproduzir rapidamente o ambiente em sua estação e assim desenvolver códigos seguindo o padrão da equipe.

Na necessidade de se testar uma nova versão de uma determinada parte da sua solução, usando imagens Docker normalmente basta a mudança de um ou mais parâmetros de um arquivo de definição para se iniciar um ambiente modificado com a versão requerida para a avaliação, ou seja, criar e modificar sua infraestrutura ficou bem mais fácil e rápido.

### 4 – Idioma comum entre Infraestrutura e desenvolvimento

A sintaxe usada para parametrizar as imagens e ambientes Docker pode ser considerada um idioma comum entre áreas que costumeiramente não dialogavam bem, ou seja, agora é possível ambos setores apresentarem propostas e contra propostas com base em um documento em comum.

A infraestrutura requerida estará presente no código do desenvolvedor e a área de infraestrutura poderá analisar esse documento, sugerindo mudanças para adequação de padrões do seu setor ou não. Tudo isso em comentários e aceitação de *merge* ou *pull request* do sistema de controle de versão de códigos.

### 5 – Comunidade

Assim como hoje é possível acessar o [github](http://github.com/) ou [gitlab](https://about.gitlab.com/) a procura de exemplos de código, usando o [repositório de imagens do Docker](http://hub.docker.com/) é possível conseguir alguns bons modelos de infraestrutura de aplicações, assim como serviços prontos para integrações complexas.

Um exemplo é o [nginx](https://hub.docker.com/_/nginx/) como proxy reverso e [mysql](https://hub.docker.com/_/mysql/) como banco de dados. Caso sua aplicação necessite desses dois recursos, você não precisa perder tempo instalando e configurando totalmente esses serviços, basta utilizar as imagens do repositório, configurando parâmetros mínimos para adequação com seu ambiente. Normalmente as imagens oficiais seguem as boas práticas de uso dos serviços oferecidos.

Utilizar essas imagens não significa ficar “refém” da configuração trazida com elas, pois é possível enviar sua própria configuração para esses ambientes e evitar apenas o trabalho da sua instalação básica.

### Dúvidas

Algumas pessoas enviaram dúvidas relacionadas as vantagens que explicitei nesse texto, sendo assim ao invés de respondê-las pontualmente, resolvi publicar as perguntas e minhas respectivas respostas aqui.

#### Qual a diferença entre imagem Docker e definições criadas por ferramenta de [automação de infraestrutura](http://www.ibm.com/developerworks/br/library/a-devops2/)?

Como exemplo de ferramentas de automação de infraestrutura temos o [Puppet](https://puppetlabs.com/), [Ansible](https://www.ansible.com/) e [Chef](https://www.chef.io/chef/). Todas elas podem garantir ambientes parecidos, uma vez que faz parte do seu papel manter uma determinada configuração no ativo desejado.

A diferença entre a solução Docker e gerência de configuração pode parecer bem tênue, pois ambas podem suportar a configuração necessária de toda infraestrutura que uma aplicação demanda para ser implantada, mas acho que uma das distinções mais relevante está no fato da imagem ser uma abstração completa e não requerer qualquer tratamento para lidar com as mais variadas distribuições GNU/Linux existentes, pois a imagem Docker carrega em si uma copia completa dos arquivos de uma distribuição enxuta.

Carregar em si essa cópia de uma distribuição GNU/Linux normalmente não é um problema para o Docker, pois utilizando o modelo de camadas do Docker ele economizará bastante recurso reutilizando as camadas de base. Leia [esse artigo](http://techfree.com.br/2015/12/entendendo-armazenamentos-de-dados-no-docker/) para entender um pouco mais de armazenamento do Docker.

Outra vantagem da imagem em relação a gerência de configuração é o fato de que utilizando a imagem é possível disponibilizar o pacote completo da aplicação em um repositório e esse “produto final” ser utilizado facilmente sem necessidade de configuração completa. Apenas um arquivo de configuração e apenas um comando normalmente são o suficiente para iniciar uma aplicação criada como imagem Docker.

Ainda sobre o processo de imagem Docker como produto no repositório, isso pode ser usado também no processo de atualização da aplicação, como já explicamos nesse capítulo.

#### O uso da imagem base no Docker de uma determinada distribuição não é a mesma coisa que criar uma definição de gerência de configuração para uma distribuição?

Não! A diferença está na perspectiva do hospedeiro, pois no caso do Docker não importa qual distribuição GNU/Linux utilizada no host, pois há uma parte da imagem que carrega todos os arquivos de uma mini distribuição, que será o suficiente para suportar tudo que a aplicação precisa, ou seja, caso seu Docker host seja Fedora e o fato de sua aplicação em questão precisa de arquivos do Debian, não se preocupe, pois a imagem em questão trará arquivos Debian para suportar seu ambiente e como já foi dito anteriormente, isso normalmente não chega a impactar negativamente no consumo de espaço em disco.

#### Quer dizer então que agora eu, desenvolvedor, preciso me preocupar com tudo da Infraestrutura?

Não! Quando citamos que é possível o desenvolvedor especificar a infraestrutura, estamos falando que é aquela camada mais próxima da aplicação e não toda arquitetura necessária (Sistema operacional básico, regras de firewall, rotas de rede e etc).

A ideia do Docker é que os assuntos relevantes e diretamente ligados a aplicação possam ser configurados pelo desenvolvedor, mas isso não o obriga a realizar essa atividade, é uma possibilidade que agrada muitos desenvolvedores, mas caso não seja esse sua situação, pode ficar tranquilo que outra equipe tratará dessa parte. Apenas o seu processo de implantação será um pouco mais lento.

#### Muitas pessoas falam de Docker para [micro serviços](https://www.thoughtworks.com/pt/insights/blog/microservices-nutshell), é possível usar o Docker para aplicações monolíticas?

Sim! Porém em alguns casos será necessário fazer pequenas modificações em sua aplicação, para que ela possa usufruir das facilidades do Docker. Um exemplo comum é o log, que normalmente a aplicação envia para determinado arquivo, ou seja, no modelo Docker as aplicações que estão nos containers não devem tentar escrever ou gerir arquivos de logs. Ao invés disso, cada processo em execução escreve seu próprio fluxo de evento, sem buffer, para o [stdout](https://pt.wikipedia.org/wiki/Fluxos_padr%C3%A3o), pois o Docker tem drivers específicos para tratar o log enviado dessa forma. Essa parte de melhores práticas de gerenciado de logs será detalhada em capítulos posteriores.

Em alguns momento você perceberá que o uso do Docker para sua aplicação demanda muito esforço, nesses casos normalmente o problema está mais em como sua aplicação trabalha do que na configuração do Docker. Esteja atento.

Você tem mais dúvidas e/ou bons motivos para utilizar Docker? Comente [aqui](http://techfree.com.br/2016/03/porque-usar-docker/).



