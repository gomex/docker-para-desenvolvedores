# Transformando sua aplicação em contêiner

Evoluímos continuamente para entregar aplicações cada vez melhores, em menor tempo, replicáveis e escaláveis. Entretanto, os esforços e aprendizados para atingir esse nível de maturidade muitas vezes não são simples de serem alcançados.

Atualmente, notamos o surgimento de várias opções de plataformas para facilitar a implantação, configuração e escalabilidade das aplicações que desenvolvemos. Porém, para melhorar nossa maturidade, não podemos depender apenas da plataforma, precisamos construir nossa aplicação seguindo boas práticas.

Visando sugerir uma série de boas práticas comuns a aplicações web modernas, alguns desenvolvedores do [Heroku](https://www.heroku.com/) escreveram o [12Factor app](https://12factor.net/pt_br/), baseado na larga experiência em desenvolvimento desse tipo de aplicação.

![](images/12factor.gif)

"The Twelve-Factor app" (12factor) é um manifesto com uma série de boas práticas para construção de software utilizando formatos declarativos de automação, maximizando portabilidade e minimizando divergências entre ambientes de execução, permitindo a implantação em plataformas de nuvem modernas e facilitando a escalabilidade. Assim, aplicações são construídas sem manter estado (stateless) e conectadas a qualquer combinação de serviços de infraestrutura para retenção de dados (banco de dados, fila, memória cache e afins).

Nesse capítulo, falaremos sobre criação de aplicações com imagens Docker baseados no 12factor app. A ideia é demonstrar as melhores práticas para realizar a criação de infraestrutura para suportar, empacotar e disponibilizar a aplicação com alto nível de maturidade e agilidade.

O uso do 12factor com Docker é uma combinação perfeita, pois muitos dos recursos do Docker são melhores aproveitados caso a aplicação tenha sido pensada para tal. Dessa forma, daremos uma ideia de como aproveitar todo potencial da sua solução.

Como aplicação exemplo, teremos um serviço HTTP, escrito em python, que exibe quantas vezes foi acessada. Essa informação é armazenada através de contador numa instância Redis.

Agora vamos às boas práticas!
