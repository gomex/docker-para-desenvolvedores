## Container ou máquina virtual?

Após o sucesso repentino do Docker, que utiliza a virtualização com base em containers, muitas pessoas tem se questionado sobre uma possível migração do modelo de máquina virtual para containers.

![](images/contaier_vm.png)

Eu respondo tranquilamente: **Os dois!**

Ambos são métodos de virtualização, mas elas atuam em “camadas” distintas. Vale a pena detalhar cada solução para deixar claro que elas não são necessariamente concorrentes.

### Máquina virtual

Um conceito bem antigo, oriundo dos Mainframes em meados de 1960, onde cada operador desse ambiente tinha a visão de estar acessando uma máquina dedicada, mas na verdade todo recurso do Mainframe era compartilhado para todos operadores.

O objetivo desse modelo é compartilhar os recursos físicos entre vários ambientes isolados, sendo que cada um deles tem sob sua tutela uma máquina inteira, com memória, disco, processador, rede e outros periféricos, todos entregues via abstração de virtualização.

É como se dentro de uma máquina física criasse máquinas menores e independentes entre sí. Cada máquina dessa tem seu próprio sistema operacional completo, que por sua vez interage com todos os hardwares virtuais que lhe foi entregue pelo modelo de virtualização a nível de máquina.

Vale ressaltar que o sistema operacional instalado dentro de uma máquina virtual fará interação com os hardwares virtuais e não com o hardware real.

![](images/vm.png)

Com a evolução desse modelo, os softwares que implementam essa solução puderam oferecer mais funcionalidades, tal como melhor interface para gerência de ambientes virtuais e alta disponibilidade utilizando vários hosts físicos.

Com as novas funcionalidades de gerência de ambientes de máquinas virtuais é possível especificar quanto recurso físico cada ambiente virtual usará e até mesmo aumentar gradualmente em caso de necessidade pontual.

Atualmente as máquinas virtuais são uma realidade para qualquer organização que necessite de um ambiente de TI, pois facilita a gerência das máquinas físicas e seu compartilhamento entre os diversos ambientes necessários para sua infraestrutura básica.

### Container

Esse modelo de virtualização está no nível de sistema operacional, ou seja, ao contrário da máquina virtual um container não tem visão de uma máquina inteira, ele é apenas um processo em execução em um kernel compartilhado entre todos os outros containers.

Ele utiliza o namespace para prover o devido isolamento de memória RAM, processamento, disco e acesso à rede, ou seja, mesmo compartilhando o mesmo kernel, esse processo em execução tem a visão de estar usando um sistema operacional dedicado.

Esse modelo de virtualização é relativamente antigo, meados de 1982 o chroot já fazia algo que podemos considerar que era uma virtualização a nível de sistema operacional e em 2008 o LXC já fazia algo relativamente parecido ao que o Docker faz hoje. Inclusive o Docker usava o LXC no início, mas hoje já tem interface própria para acessar o namespace, cgroup e afins.

![](images/container_vm2.png)

Como solução inovadora, o Docker trás diversos serviços e novas facilidades que deixam esse modelo muito mais atrativo.

A configuração de um ambiente LXC não era uma tarefa relativamente simples. Era necessário algum conhecimento técnico médio para criar e manter um ambiente com ele. Com advento do Docker esse processo ficou bem mais simples. Basta instalar o binário, baixar as imagens e executá-las.

Outra novidade do Docker foi a criação do conceito de “imagens”, que grosseiramente podemos descrever que as imagens são definições estáticas de como os containers devem ser no momento da sua inicialização. São como fotografias de um ambiente. Uma vez instanciadas, colocadas em execução, elas assumem a função de containers, ou seja, saem da abstração de definição e se transformam em processos em execução, dentro de um contexto isolado, que enxergam um sistema operacional dedicado pra sí, mas na verdade compartilham o mesmo kernel.

Junto a facilidade de uso dos containers, o Docker agregou o conceito de nuvem, que dispõe de serviço um para carregar e “baixar” imagens Docker, ou seja, se trata de uma aplicação web que disponibiliza um repositório de ambientes prontos, onde viabilizou um nível absurdo de compartilhamento de ambientes.

Com o uso do serviço de nuvem do Docker, podemos perceber que a adoção do modelo de containers ultrapassa a questão técnica e adentra nos assuntos de processo, gerência e atualização do ambiente. Onde agora é possível compartilhar facilmente as mudanças e viabilizar uma gestão centralizada das definições de ambiente.

Utilizando a nuvem Docker agora é possível disponibilizar ambientes de teste mais leves. Isso permite a situação onde em plena reunião com seu chefe você pode baixar aquela solução para um problema que ele descreve e mostrar antes que ele saia da sala. Permite também que você consiga disponibilizar um padrão de melhores práticas para um determinado serviço e compartilhar com todos da sua empresa ou mundo, onde pode receber críticas e modificar com o passar do tempo.

### Conclusão

Com os dados apresentados, podemos perceber que o ponto de conflito entre as soluções é baixo. Elas podem e normalmente são adotadas em conjunto. Você pode provisionar uma máquina física com um servidor de máquinas virtuais, onde serão criadas máquinas virtuais hospedes, que por sua vez terão o docker instalado em cada máquina. Nesse docker serão disponibilizados os ambientes com seus respectivos serviços segregados, cada um em um container.

Percebam que teremos vários níveis de isolamento. No primeiro temos uma máquina física que foi repartida em várias máquinas virtuais, ou seja, já temos nessa camada sistemas operacionais interagindo com hardwares virtuais distintos, como placas de rede virtuais, discos, processo e memória. Nesse ambiente teríamos apenas o sistema operacional básico instalado e o docker.

No segundo nível de isolamento, temos o Docker baixando as imagens prontas e provisionamento containers em execução, que por sua vez criam novos ambientes isolados, a nível de processamento, memória, disco e rede. Nesse caso podemos ter na mesma máquina virtual um ambiente de aplicação web e banco de dados, mas em containers diferentes e isso não seria nenhum problema de boas práticas de gerência de serviços, muito menos de segurança.

![](images/maquinavirtual_e_containers.png)

Caso esses containers sejam replicados entre as máquinas virtuais, seria possível prover alta disponibilidade sem grandes custos, ou seja, usando um balanceador externo e viabilizando o cluster dos dados persistidos pelos bancos de dados.

Toda essa facilidade com poucos comandos, recursos e conhecimento. Basta um pouco de tempo para mudar o paradigma de gerência dos ativos e paciência para lidar com os novos problemas inerentes do modelo.

[Capítulo anterior: Apêndice](apendice.md)