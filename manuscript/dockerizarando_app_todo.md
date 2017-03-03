# Transformando sua aplicação em container

Estamos evoluindo continuamente para entregar aplicações cada vez melhores, em menor tempo, replicáveis e escaláveis. Porém os esforços e aprendizados para atingir esse nível de maturidade muitas vezes não são simples de se alcançar.

Atualmente notamos o surgimento de várias opções de plataformas para facilitar a implantação, configuração e escalabilidade das aplicações que desenvolvemos. Porém, para melhorar nossa maturidade não podemos apenas depender da plataforma, precisamos construir nossa aplicação seguindo boas práticas.

Visando sugerir uma série de boas práticas comuns a aplicações web modernas, alguns desenvolvedores do [Heroku](https://www.heroku.com/) escreveram o [12Factor app](http://12factor.net/pt_br/), baseado em uma larga experiência em desenvolvimento desse tipo de aplicação.

![](images/12factor.gif)

"The Twelve-Factor app" (12factor) é um manifesto com uma série de boas práticas para construção de software utilizando formatos declarativos de automação, maximizando portabilidade e minimizando divergências entre ambientes de execução, permitindo a implantação em plataformas de nuvem modernas e facilitando a escalabilidade. Assim, aplicações são construídas sem manter estado (stateless) e conectadas a qualquer combinação de serviços de infraestrutura para retenção de dados (Banco de dados, fila, memória cache e afins).

Nesse capítulo falaremos sobre criação de aplicações como imagens docker com base no 12factor app, ou seja, a ideia é demonstrar as melhores práticas de como se realizar a criação de uma infraestrutura para suportar, empacotar e disponibilizar a sua aplicação com alto nível de maturidade e agilidade.

O uso do 12factor com Docker é uma combinação perfeita, pois muitos dos recursos do Docker são melhores aproveitados caso sua aplicação tenha sido pensada para tal. Dessa forma, nesse texto daremos uma ideia de como aproveitar todo potencial da sua solução.

Como exemplo, usaremos duas aplicações como modelo. Uma usando linguagem dinâmica (Python) e outra compilada (Java).

Como exemplo teremos um modelo de aplicação simples. Através de um serviço HTTP, ela exibe quantas vezes foi acessada. Essa informação é armazenada através de um contador numa instância Redis.

Agora vamos às boas práticas!
