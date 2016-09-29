# O que é Docker

De forma bem resumida podemos dizer que o Docker é uma plataforma aberta criada com objetivo de facilitar o desenvolvimento, implantação e execução de aplicações em ambientes isolados. Ela foi desenhada especialmente para disponibilizar sua aplicação da forma mais rápida possível.

![](images/docker.jpg)

Usando o Docker você pode gerenciar facilmente a infraestrutura da sua aplicação, ou seja, isso agilizará o processo de criação, manutenção e modificação do seu serviço. 

Todo processo é realizado sem a necessidade de qualquer acesso privilegiado à sua infraestrutura corporativa, ou seja, a equipe responsável pela aplicação poderá participar da especificação do ambiente junto com a equipe responsável pelos servidores.

O Docker viabilizou uma "linguagem" comum entre desenvolvedores e administradores de servidores. Esse novo "idioma" é utilizado para construir arquivos com as definições da infraestrutura necessária, como a aplicação será disposta nesse ambiente, em qual porta fornecerá seu serviço, quais dados de volumes externos serão requisitados e outras possíveis necessidades.

O Docker disponibiliza também uma nuvem pública para compartilhamento de ambientes prontos, que podem ser utilizados para viabilizar customizações para ambientes específicos, ou seja, é possível obter uma imagem pronta do apache e configurar os módulos específicos necessários para sua aplicação e assim criar seu próprio ambiente customizado. Tudo isso com poucas linhas de descrição.

O Docker utiliza o modelo de container para “empacotar” sua aplicação, que após ser transformada em uma imagem Docker, poderá ser reproduzida em plataforma de qualquer porte, ou seja, caso sua aplicação funcione sem falhas em seu notebook, ela funcionará também no servidor ou no mainframe. Construa uma vez, execute onde quiser.

Os containers são isolados a nível de disco, memória, processamento e rede. Essa separação permite uma grande flexibilidade, onde ambientes distintos podem coexistir no mesmo host, sem causar qualquer problema. Vale salientar que o overhead nesse processo é o mínimo necessário, pois cada container normalmente carrega apenas um processo, que é aquele responsável pela entrega do serviço desejado, em todo caso esse container também carregam todos os arquivos necessários (configuração, biblioteca e afins) para sua execução completamente isolada.

Outro ponto interessante no Docker é sua velocidade para viabilizar o ambiente desejado, pois como é basicamente o início de um processo e não um sistema operacional inteiro, o tempo de disponibilização é normalmente medido em segundos.

### Virtualização a nível do sistema operacional

O modelo de isolamento utilizado no Docker é a virtualização a nível do sistema operacional, que é um método de virtualização onde o kernel do sistema operacional permite que múltiplos processos sejam executados isoladamente no mesmo host. Esses processos isolados em execução são denominados no Docker de container.

![](images/docker2.png)

Para criar o isolamento necessário desse processo, o Docker usa a funcionalidade do kernel denominada de [namespaces](http://man7.org/linux/man-pages/man7/namespaces.7.html), que cria ambientes isolados entre containers, ou seja, os processos de uma aplicação em execução não terão acesso aos recursos de outra, a não ser que isso seja expressamente liberado na configuração de cada ambiente.

Para evitar a exaustão dos recursos da máquina por apenas um ambiente isolado, o Docker usa a funcionalidade [cgroups](https://en.wikipedia.org/wiki/Cgroups) do kernel, que é responsável por criar limites de uso do hardware a disposição. Com isso é possível coexistir no mesmo host diferentes containers, sem que um afete diretamente o outro por uso exagerado dos recursos compartilhados. 
