# Prayer Catalog & Content Full Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add all ~80 prayers from the PDF to the app with full text content, organized by theme/category.

**Architecture:** 
- Update `oracoes_catalog.json` with all prayers (catalog entries)
- Create individual JSON files for prayers with verses/structure (PT + LAT combined)
- Store simple prayers directly in catalog

**Tech Stack:** Flutter, JSON asset files

**Source PDF:** `/Users/gabrielttav/Downloads/oracoes.pdf`

---

## Task 1: Update oracoes_catalog.json with All Prayers

**Files:**
- Modify: `iacula_app/assets/seed/prayers/pt-br/oracoes_catalog.json`

**Step 1: Backup and replace the catalog file**

Write the complete catalog with all ~80 prayers:

```json
[
  {"id": "sinal-da-cruz", "title": "Sinal da Cruz", "content": "Em nome do Pai e do Filho e do Espírito Santo. Amém.", "theme": ["oracoes-comuns"], "saints": []},
  {"id": "gloria", "title": "Glória", "content": "Glória ao Pai e ao Filho e ao Espírito Santo. Como era, no princípio, agora e sempre. Amém.", "theme": ["oracoes-comuns"], "saints": []},
  {"id": "pai-nosso", "title": "Pai Nosso", "content": "Pai nosso que estais nos céus, santificado seja o vosso nome; venha a nós o vosso reino, seja feita a vossa vontade assim na terra como no céu. O pão nosso de cada dia nos dai hoje; perdoai-nos as nossas ofensas assim como nós perdoamos a quem nos tem ofendido, e não nos deixeis cair em tentação, mas livrai-nos do mal. Amém.", "theme": ["oracoes-comuns"], "saints": []},
  {"id": "ave-maria", "title": "Ave Maria", "content": "Ave Maria, cheia de graça, o Senhor é convosco, bendita sois vós entre as mulheres e bendito é o fruto do vosso ventre, Jesus. Santa Maria, Mãe de Deus, rogai por nós pecadores, agora e na hora da nossa morte. Amém.", "theme": ["oracoes-comuns", "mariano"], "saints": ["virgem-maria"]},
  {"id": "salve-rainha", "title": "Salve Rainha", "content": "Salve Rainha, Mãe de misericórdia, vida, doçura, esperança nossa, salve! A vós bradamos, os degredados filhos de Eva, a vós suspiramos, gemendo e chorando neste vale de lágrimas. Eia, pois, Advogada nossa, esses vossos olhos misericordiosos a nós volvei, e depois deste desterro mostr-nos Jesus, bendito fruto de vosso ventre, ó clemente, ó piedosa, ó doce sempre Virgem Maria.", "theme": ["mariano"], "saints": ["virgem-maria"]},
  {"id": "ato-de-contricao", "title": "Ato de Contrição", "content": "Senhor, eu me arrependo sinceramente de todo mal que pratiquei e do bem que deixei de fazer. Pecando, eu vos ofendi, meu Deus e sumo bem, digno de ser amado sobre todas as coisas. Prometo firmemente, ajudado com a vossa graça, fazer penitência e fugir às ocasiões de pecar. Amém.", "theme": ["oracoes-comuns", "penitencia"], "saints": []},
  {"id": "credo", "title": "Credo", "content": "Creio em um só Deus, Pai todo-poderoso, Criador do céu e da terra, de todas as coisas visíveis e invisíveis. Creio em um só Senhor, Jesus Cristo, Filho Unigênito de Deus, nascido do Pai antes de todos os séculos: Deus de Deus, luz da luz, Deus verdadeiro de Deus verdadeiro, gerado não criado, consubstancial ao Pai. Por Ele todas as coisas foram feitas. E, por nós, homens, e para a nossa salvação, desceu dos céus: e encarnou pelo Espírito Santo, no seio da Virgem Maria, e se fez homem. Também por nós foi crucificado sob Pôncio Pilatos; padeceu e foi sepultado. Ressuscitou ao terceiro dia, conforme as escrituras, e subiu aos céus, onde está sentado à direita do Pai. E de novo há de vir, em sua glória, para juzgar os vivos e os mortos; e o seu reino não terá fim. Creio no Espírito Santo, Senhor que dá a vida, e procede do Pai; e com o Pai e o Filho é adorado e glorificado: Ele que falou pelos profetas. Creio na Igreja una, santa, católica e apostólica. Professo um só batismo para remissão dos pecados. Espero a ressurreição dos mortos e a vida do mundo que há de vir. Amém.", "theme": ["oracoes-comuns"], "saints": []},
  {"id": "credo-apostolico", "title": "Credo Apostólico", "content": "Creio em Deus Pai todo-poderoso, criador do céu e da terra; e em Jesus Cristo, seu único Filho, nosso Senhor; que foi concebido pelo poder do Espírito Santo; nasceu da Virgem Maria, padereceu sob Pôncio Pilatos, foi crucificado, morto e sepultado; desceu à mansão dos mortos; ressuscitou ao terceiro dia; subiu aos céus, está sentado à direita de Deus Pai todo-poderoso, donde há de vir a juzgar os vivos e os mortos; creio no Espírito Santo, na Santa Igreja Católica, na comunhão dos Santos, na remissão dos pecados, na ressurreição da carne, na vida eterna. Amém.", "theme": ["oracoes-comuns"], "saints": []},
  {"id": "ao-anjo-da-guarda", "title": "Ao Anjo da Guarda", "content": "Santo Anjo do Senhor, meu zeloso guardador, pois que a ti me confiou a Piedade divina, hoje e sempre me governa, rege, guarda e ilumina. Amém.", "theme": ["oracoes-comuns", "protecao"], "saints": ["anjos"]},
  {"id": "simbolo-atanasiano", "title": "Símbolo Atanasiano", "content": "Quem quiser salvar-se deve antes de tudo professar a fé católica. Porque aquele que não a professar, integral e inviolavelmente, perecerá sem dúvida por toda a eternidade. A fé católica consiste em adorar um só Deus em três Pessoas e três Pessoas em um só Deus. Sem confundir as Pessoas nem separar a substância. Porque uma só é a Pessoa do Pai, outra a do Filho, outra do Espírito Santo. Mas uma só é a divindade do Pai, e do Filho, e do Espírito Santo, igual a glória, coeterna a majestade. Tal como é o Pai, tal é o Filho, tal é o Espírito Santo. O Pai é incriado, o Filho é incriado, o Espírito Santo é incriado. O Pai é imenso, o Filho é imenso, o Espírito Santo é imenso. O Pai é eterno, o Filho é eterno, o Espírito Santo é eterno. E contudo não são três eternos, mas um só eterno. Assim como não são três incriados, nem três imensos, mas um só incriado e um só imenso. Da mesma maneira, o Pai é onipotente, o Filho é onipotente, o Espírito Santo é onipotente. E contudo não são três onipotentes, mas um só onipotente. Assim o Pai é Deus, o Filho é Deus, o Espírito Santo é Deus. E contudo não são três deuses, mas um só Deus. Do mesmo modo, o Pai é Senhor, o Filho é Senhor, o Espírito Santo é Senhor. E contudo não são três senhores, mas um só Senhor. O Pai não foi feito, nem gerado, nem criado por ninguém. O Filho procede do Pai; não foi feito, nem criado, mas gerado. O Espírito Santo não foi feito, nem criado, nem gerado, mas procede do Pai e do Filho. Não há, pois, senão um só Pai, e não três Pais; um só Filho, e não três Filhos; um só Espírito Santo, e não três Espíritos Santos. E nesta Trindade não há nem mais antigo nem menos antigo, nem maior nem menor, mas as três Pessoas são coeternas e iguais entre si.", "theme": ["santissima-trindade"], "saints": []},
  {"id": "te-deum", "title": "Te Deum", "content": "A vós, ó Deus, nosso louvor! Nós vos aclamamos: sois o Senhor! A vós, Pai eterno, o hino do universo. Diante de vós prosternam-se os arcanjos, os anjos e os espíritos celestiais; eles vos dão graças, vos adoram e cantam: Santo, Santo, Santo é o Senhor Deus do universo; o céu e a terra estão cheios de vossa glória. É a vós que os apóstolos glorificam, a vós que os profetas proclamam, de quem os mártires dão testemunho; é a vós que, pelo mundo inteiro, a Igreja anuncia e reconhece. Deus, nós vos adoramos: Pai infinitamente santo, Filho eterno e bem-amado, Espírito de poder e de paz.", "theme": ["santissima-trindade"], "saints": []},
  {"id": "ato-de-fe", "title": "Ato de Fé", "content": "Eu creio firmemente que há um só Deus em três pessoas realmente distintas, Pai, Filho e Espírito Santo; que dá o céu aos bons e o inferno aos maus, para sempre. Creio que o Filho de Deus se fez homem, padeceu e morreu na cruz para nos salvar, e ao terceiro dia ressuscitou. Creio em tudo mais que crê e ensina a Igreja Católica, Apostólica, Romana, porque Deus, verdade infalível, lho revelou. Nesta crença quero viver e morrer.", "theme": ["santissima-trindade"], "saints": []},
  {"id": "ato-de-esperanca", "title": "Ato de Esperança", "content": "Eu espero, meu Deus, com firma confiança, que pelos merecimentos de nosso Senhor Jesus Cristo, me dareis a salvação eterna e as graças necessárias para consegui-la, porque vós, SUMAMENTE bom e poderoso, o havia promise a quem observar os mandamentos e o evangelho de Jesus, como eu proponho fazer com o vosso auxílio.", "theme": ["santissima-trindade"], "saints": []},
  {"id": "ato-de-caridade", "title": "Ato de Caridade", "content": "Eu vos amo, ó meu Deus, de todo o meu coração e sobre todas as coisas, porque sois infinitamente amável e bom, e antes quero perder tudo do que vos ofender. Por amor de Vós, amo ao meu próximo como a mim mesmo e perdôo as ofensas recebidas. Senhor, fazei que eu vos ame sempre mais!", "theme": ["santissima-trindade"], "saints": []},
  {"id": "visita-ao-santissimo", "title": "Visita ao Santíssimo", "content": "V/. Graças e louvores sejam dados a todo momento. R/. Ao santíssimo e diviníssimo Sacramento. Pai-Nosso, Ave-Maria e Glória. Comunhão espiritual: Eu quisera, Senhor, receber-vos com aquela pureza, humildade e devoção com que vos recebeu a vossa Santíssima Mãe, com o espírito e o fervor dos Santos.", "theme": ["eucaristica"], "saints": []},
  {"id": "adoro-te-devote", "title": "Adoro te Devote", "content": "Adoro-Vos com devoção, Deus escondido, que sob estas aparências estais presente. A Vós se submete meu coração por inteiro, e ao contemplar-Vos se rende totalmente. A vista, o tato, o gosto sobre Vós se enganam, mas basta o ouvido para crer com firmeza. Creio em tudo o que disse o Filho de Deus; nada mais verdadeiro que esta palavra de verdade. Na Cruz estava oculta a divindade, mas aqui se esconde também a humanidade; creio, porém, e confesso uma e outra, e peço o que pediu o ladrão arrependido.", "theme": ["eucaristica"], "saints": []},
  {"id": "pange-lingua", "title": "Pange Lingua", "content": "Celebremos o mistério da divina Eucaristia, Corpo e Sangue de Jesus: o mistério do Deus vivo, tão real no seu altar como outrora sobre a Cruz. Veneremos, adoremos a presença do senhor, nossa Luz e Pão da Vida. Cante a alma o seu louvor. Adoremos no sacrário Deus oculto por amor. Demos glória ao Pai do Céu, Infinita Majestade, glória ao Filho e ao Espírito Santo.", "theme": ["eucaristica"], "saints": []},
  {"id": "veni-creator", "title": "Veni Creator", "content": "Vinde, Espírito Criador, visitai a alma dos vossos fiéis; enchei de graça celestial os corações que Vós criastes. Vós, chamado o Consolador, dom do Deus altíssimo, fonte viva, fogo, caridade e unção espiritual. Vós, com vossos sete dons, sois força da destra de Deus, Vós, o promise pelo Pai; a vossa palavra enriquece nossos lábios.", "theme": ["espirito-santo"], "saints": []},
  {"id": "vinde-espirito-criador", "title": "Vinde, Espírito Criador", "content": "Vinde, Espírito Criador, visitai a alma dos vossos fiéis; enchei de graça celestial os corações que Vós criastes. Vós, chamado o Consolador, dom do Deus altíssimo, fonte viva, fogo, caridade e unção espiritual.", "theme": ["espirito-santo"], "saints": []},
  {"id": "veni-sancte-spiritus", "title": "Veni, Sancte Spiritus", "content": "Vinde Santo Espírito e do céu mandai luminoso raio; vinde pai dos pobres, doador dos dons, luz dos corações. Grande defensor em nós habitais e nos confortais. Na fadiga, pouso, no ardor, brandura e na dor, ternura. Ó luz venturosa, que vossos clarões encham os corações.", "theme": ["espirito-santo"], "saints": []},
  {"id": "vinde-santo-espirito", "title": "Vinde Santo Espírito", "content": "Vinde Santo Espírito e do céu mandai luminoso raio; vinde pai dos pobres, doador dos dons, luz dos corações. Grande defensor em nós habitais e nos confortais. Na fadiga, pouso, no ardor, brandura e na dor, ternura.", "theme": ["espirito-santo"], "saints": []},
  {"id": "anjo-do-senhor", "title": "Anjo do Senhor", "content": "V/. O anjo do Senhor anunciou a Maria. R/. E Ela concebeu do Espírito Santo. Ave Maria. V/. Eis aqui a escrava do Senhor. R/. Faça-se em mim segundo a vossa palavra. Ave Maria. V/. E o Verbo divino se fez carne. R/. E habitou entre nós. Ave Maria. V/. Rogai por nós Santa Mãe de Deus. R/. Para que sejamos dignos das graças de Cristo.", "theme": ["mariano"], "saints": ["virgem-maria"]},
  {"id": "angelus", "title": "Angelus", "content": "V/. Angelus Dómini nuntiávit Maríæ. R/. Et concépit de Spíritu Sancto. Ave, Maria. V/. Ecce ancílla Dómini. R/. Fiat mihi secúndum verbum tuum. Ave, María. V/. Et Verbum caro factum est. R/. Et habitávit in nobis. Ave, María.", "theme": ["mariano"], "saints": ["virgem-maria"]},
  {"id": "rainha-do-ceu", "title": "Rainha do Céu", "content": "V/. Rainha do Céu, alegrai-Vos, aleluia. R/. Porque quem merecestes trazer em vosso seio, aleluia. V/. Ressuscitou como disse, aleluia. R/. Rogai a Deus por nós, aleluia. V/. Exultai e alegrai-vos, ó Virgem Maria, aleluia. R/. Porque o Senhor ressuscitou verdadeiramente, aleluia.", "theme": ["mariano"], "saints": ["virgem-maria"]},
  {"id": "regina-coeli", "title": "Regina Caeli", "content": "V/. Regina cæli, lætáre, allelúia. R/. Quia quem meruísti portáre, allelúia. V/. Resurréxit, sicut dixit, allelúia. R/. Ora pro nobis Deum, allelúia. V/. Gaude et lætáre, Virgo Maria, allelúia. R/. Quia surréxit Dóminus vere, allelúia.", "theme": ["mariano"], "saints": ["virgem-maria"]},
  {"id": "lembrai-vos", "title": "Lembrai-vos", "content": "Lembrai-vos, ó piíssima Virgem Maria, que nunca se ouviu dizer que algum daqueles que recorreram à vossa proteção, imploraram a vossa assistência e reclamaram o vosso socorro, fosse por vós desamparado. Animado eu, pois, com igual confiança, a vós, Virgem, entre todas singular, como à minha Mãe recorro; de vós me valho e, gemendo sob o peso de meus pecados, me prostro aos vossos pés.", "theme": ["mariano"], "saints": ["virgem-maria"]},
  {"id": "memorare", "title": "Memorare", "content": "Memorare, O piissima Virgo Maria, non esse auditum a saeculo, quemquam ad tua currentem praesidia, tua implorantem auxilia, tua petentem suffragia, esse derelictum. Ego tali animato confidentia, ad te, Virgo Virginum, Mater, curro, ad te venio, coram te gemens peccator assisto.", "theme": ["mariano"], "saints": ["virgem-maria"]},
  {"id": "stabat-mater", "title": "Stabat Mater", "content": "De pé a Mãe dolorosa, junto da cruz, lacrimosa, via Jesus que pendia. No coração transpassado sentia o gládio enterrado de uma cruel profecia. Mãe entre todas bendita, do Filho único, aflita, a imensa dor assistia. E, suspirando, chorava, e da cruz não se afastava, ao ver que o Filho morria.", "theme": ["mariano", "paixao-de-cristo"], "saints": ["virgem-maria"]},
  {"id": "sob-a-tua-protecao", "title": "Sob a tua Proteção", "content": "À vossa proteção nós recorremos, Santa Mãe de Deus; não desprezeis as súplicas que em nossas necessidades vos dirigimos, mas livrai-nos sempre de todos os perigos, ó Virgem gloriosa e bendita.", "theme": ["mariano"], "saints": ["virgem-maria"]},
  {"id": "bendita-seja-a-tua-pureza", "title": "Bendita seja a tua Pureza", "content": "Bendita seja tua pureza e eternamente o seja, pois todo um Deus se recreia em tão graciosa beleza. A ti, celestial Princesa, Virgem Maria, vos ofereço neste dia alma, vida e coração. Olhai-me com compaixão, não me deixes, Mãe minha.", "theme": ["mariano"], "saints": ["virgem-maria"]},
  {"id": "alma-redemptoris-mater", "title": "Alma Redemptóris Mater", "content": "Alma Redemptoris Mater, quae pervia caeli Porta manes, et stella maris, succurre cadenti, Surgere qui curat, populo: tu quae genuisti, Natura mirante, tuum sanctum Genitorem Virgo prius ac posterius, Gabrielis ab ore Sumens illud Ave, peccatorum miserere.", "theme": ["mariano"], "saints": ["virgem-maria"]},
  {"id": "ave-regina-coelorum", "title": "Ave, Regina Caelorum", "content": "Ave, Regina Caelorum, Ave, Domina Angelorum: Salve, radix, salve, porta Ex qua mundo lux est orta: Gaude, Virgo gloriosa, Super omnes speciosa, Vale, o valde decora, Et pro nobis Christum exora.", "theme": ["mariano"], "saints": ["virgem-maria"]},
  {"id": "ave-maris-stella", "title": "Ave Maris Stella", "content": "Ave Estrela do Mar, Ave Mãe de Deus, Virgem para sempre, Porta ditosa dos céus. De Gabriel, o Arcanjo aquele Ave tomando, concede ao mundo a paz de Eva o nome trocando.", "theme": ["mariano"], "saints": ["virgem-maria"]},
  {"id": "rosario-portugues", "title": "Santo Rosário (Português)", "content": "Mistérios Gozosos (segunda-feira e sábado): A Anunciação, A Visitação, O Nascimento, A Purificação, O Menino-Deus no Templo. Mistérios Luminosos (quinta-feira): O Batismo, As Bodas de Caná, O Anúncio do Reino, A Transfiguração, A Eucaristia. Mistérios Dolorosos (terça e sexta-feira): A Oração no Horto, A Flagelação, A Coroação de Espinhos, A Cruz às Costas, Jesus Morre na Cruz. Mistérios Gloriosos (quarta-feira e domingo): A Ressurreição, A Ascensão, A Vinda do Espírito Santo, A Assunção, A Coroação de Maria.", "theme": ["rosario"], "saints": ["virgem-maria"]},
  {"id": "rosario-latim", "title": "Santo Rosário (Latim)", "content": "Gaudii Mystéria (feria secunda et sábbato): Annuntiatio, Visitatio, Nativitas, Presentatio, Inventio. Lucis Mystéria (feria quinta): Baptismus, Cana, Regnum, Transfiguratio, Eucharistia. Doloris Mystéria (feria tertia et sexta): Agonia, Flagellatio, Coronatio, Via Crucis, Mors. Glóriae Mystéria (feria quarta et dominica): Resurrectio, Ascensio, Pentecostes, Assumptio, Coronatio.", "theme": ["rosario"], "saints": ["virgem-maria"]},
  {"id": "ladainha-nossa-senhora", "title": "Ladainha a Nossa Senhora", "content": "Santa Maria, rogai por nós. Santa Mãe de Deus, rogai por nós. Santa Virgem das virgens, rogai por nós. Mãe de Jesus Cristo, rogai por nós. Mãe da Igreja, rogai por nós. Mãe da divina graça, rogai por nós. Mãe puríssima, rogai por nós. Mãe castíssima, rogai por nós. Mãe imaculada, rogai por nós. Mãe intacta, rogai por nós. Mãe amável, rogai por nós. Mãe admirável, rogai por nós. Mãe do bom conselho, rogai por nós. Mãe do Criador, rogai por nós. Mãe do Salvador, rogai por nós. Virgem prudentíssima, rogai por nós. Virgem veneranda, rogai por nós. Virgem digna de louvor, rogai por nós. Virgem poderosa, rogai por nós. Virgem clemente, rogai por nós. Virgem fiel, rogai por nós. Espelho da justiça, rogai por nós. Sede da Sabedoria, rogai por nós. Causa da nossa alegria, rogai por nós. Rosa mística, rogai por nós. Torre de Davi, rogai por nós. Torre de marfim, rogai por nós. Casa de ouro, rogai por nós. Arca da aliança, rogai por nós. Porta do céu, rogai por nós. Estrela da manhã, rogai por nós. Saúde dos enfermos, rogai por nós. Refúgio dos pecadores, rogai por nós. Consoladora dos aflitos, rogai por nós. Auxílio dos cristianos, rogai por nós. Rainha dos Anjos, rogai por nós. Rainha dos Patriarcas, rogai por nós. Rainha dos Profetas, rogai por nós. Rainha dos Apóstolos, rogai por nós. Rainha dos Mártires, rogai por nós. Rainha dos Confessores, rogai por nós. Rainha das Virgens, rogai por todos os Santos, rogai por nós. Rainha concebida sem pecado original, rogai por nós. Rainha assumta aos céus, rogai por nós. Rainha do Santíssimo Rosário, rogai por nós. Rainha da Família, rogai por nós. Rainha da Paz, rogai por nós.", "theme": ["rosario", "mariano"], "saints": ["virgem-maria"]},
  {"id": "preparacao-santa-missa", "title": "Preparação para a Santa Missa", "content": "À Santissima Virgem: Ó Mãe de bondade e de misericórdia, Santissima Virgem Maria, eu, miserável e indigno pecador, a Vós recorro de todo o coração e com todo o amor; e Vos suplico que, assim como estivestes de pé junto ao vosso amabilissimo Filho pendente da Cruz, me assistais também a mim, mísero pecador, e a todos os sacerdotes que hoje na Santa Igreja oferecem o Santo Sacrifício.", "theme": ["missa-preparacao"], "saints": ["virgem-maria"]},
  {"id": "a-sao-jose", "title": "A São José", "content": "São José, varão feliz, que tivestes a dita de ver e ouvir o próprio Deus, a quem muitos reis quiseram ver e não viram, ouvir e não ouviram; e não só ver e ouvir, mas ainda trazê-lo em vossos braços, beijá-lo, vesti-lo e guardá-lo! Rogai por nós, bem-aventurado São José, para que sejamos dignos das promessas de Cristo.", "theme": ["missa-preparacao"], "saints": ["sao-jose"]},
  {"id": "oracao-sao-tomas-de-aquino", "title": "Oração de São Tomás de Aquino", "content": "Ó Deus eterno e todo-poderoso, eis que me aproximo do sacramento do vosso Filho único, Nosso Senhor Jesus Cristo. Impuro, venho à fonte da misericórdia; cego, à luz da eternal claridade; pobre e indigente, ao Senhor do céu e da terra. Imploro, pois, a abundância da vossa liberalidade, para que Vos digneis curar a minha fraqueza, lavar as minhas manchas, iluminar a minha cegueira, enriquecer a minha pobreza, vestir a minha nudez.", "theme": ["missa-preparacao"], "saints": ["sao-tomas-de-aquino"]},
  {"id": "ato-de-fe-missa", "title": "Ato de Fé (Missa)", "content": "Ó Jesus, Deus e homem verdadeiro, creio firmemente que, por nosso amor e para ser o alimento da nossa alma, estais no Santíssimo Sacramento do Altar, tão real e perfeitamente como estais no Céu.", "theme": ["missa-preparacao"], "saints": []},
  {"id": "ato-de-adoracao", "title": "Ato de Adoração", "content": "Ó Jesus, adoro-Vos profundamente neste diviníssimo Sacramento, onde estais presente como na glória dos céus. Creio que estais realmente presente no Altar, sob as aparências do Pão e do Vinho, Vós que criastes todas as coisas e redeemistes o mundo com o vosso Sangue.", "theme": ["missa-preparacao"], "saints": []},
  {"id": "ato-de-esperanca-missa", "title": "Ato de Esperança (Missa)", "content": "Ó Jesus, esperança minha, confio na vossa bondade e infinita misericórdia. Venho a Vós com a certeza de que me haveis de dar a graça da salvação e a vida eterna, pois Vós o haveis promise a todos os que Vos receberem dignamente.", "theme": ["missa-preparacao"], "saints": []},
  {"id": "ato-de-amor-missa", "title": "Ato de Amor (Missa)", "content": "Ó Jesus, meu amor, eu Vos amo de todo o meu coração e sobre todas as coisas, porque fostes Vós que primeiro me amastes e Vos entregastes por mim na Cruz. Que o meu coração se abra para Vos receber com fervor e devoção.", "theme": ["missa-preparacao"], "saints": []},
  {"id": "palavras-sao-josemaria", "title": "Palavras de São Josemaria", "content": "Ó meu Jesus, fazei que eu me aproxime de Vós comovidamente, com o desejo de Vos amar e servir, de fazer a Vossa vontade em todas as coisas, deVos acompanhar com fervor durante toda a Santa Missa.", "theme": ["missa-preparacao"], "saints": ["sao-josemaria"]},
  {"id": "oracao-santo-ambrosio", "title": "Oração de Santo Ambrósio", "content": "Ó Deus, que preparastes o vosso povo redimido para a glória eterna, fazei que as almas dos fiéis que dormem no Senhor descansem em paz e na luz da vossa face. Por Jesus Cristo, Senhor nosso.", "theme": ["missa-preparacao"], "saints": ["santo-ambrosio"]},
  {"id": "ao-espirito-santo-missa", "title": "Ao Espírito Santo (Missa)", "content": "Vinde, Espírito Criador, visitai a alma dos vossos fiéis; enchei de graça celestial os corações que Vós criastes. Dai-me a compreender a grandeza do sacrifício que vou offererece e a participar dos seus frutos eternos.", "theme": ["missa-preparacao"], "saints": []},
  {"id": "comunhoes-espirituais", "title": "Comunhões Espirituais", "content": "Creio, meu Jesus, que estais presente no Santíssimo Sacramento. Venho a Vós com fervor, desejando receber-Vos espiritualmente, pois não posso receber-Vos Sacramentalmente neste momento. Fazei que esta comunhão espiritual me seja proveitosa.", "theme": ["missa-preparacao"], "saints": []},
  {"id": "invocacoes-santisimo-redentor", "title": "Invocações ao Santíssimo Redentor", "content": "Ó Santíssimo Redentor, que Vos offerrecestes na Cruz pelo mundo inteiro, recebei as minhas ações de graças e abençoai todas as graças que recebi na Santa Missa.", "theme": ["missa-acao-de-gracas"], "saints": []},
  {"id": "oracao-sao-tomas-acao-de-gracas", "title": "Oração de São Tomás de Aquino (Ação de Graças)", "content": "Ó Deus, de quem procede todo o bem, que nos haveis nutrido com o Cuerpo e Sangue de vosso Filho, concedei-nos a graça de Vos render ações de graças e de vivir de modo que sejamos dignos de tão grandes benefícios.", "theme": ["missa-acao-de-gracas"], "saints": ["sao-tomas-de-aquino"]},
  {"id": "oracao-aojesus-crucificado", "title": "Oração a Jesus Crucificado", "content": "Ó Jesus, que na Cruz derramastes todo o vosso Sangue e morrestes por amor de nós, grazias Vos dou pela salvação que me haveis conquistado. Dai-me a graça de morrer amando-Vos e de ir gozar da vossa glorya no céu.", "theme": ["missa-acao-de-gracas"], "saints": []},
  {"id": "oracao-sao-boaventura", "title": "Oração de São Boaventura", "content": "Ó Deus, que iluminastes São Boaventura com a luz da sabedoria divina, concedei-me que, seguindo os seus ensinamentos, walk in vossos caminhos e alcance a glória eterna.", "theme": ["missa-acao-de-gracas"], "saints": ["sao-boaventura"]},
  {"id": "oracao-papa-clemente-xi", "title": "Oração do Papa Clemente XI", "content": "Agradeço-Vos, ó meu Deus, pelos benefícios que recebi de vossa mão liberal. Ofereço-Vos o meu coração, que Vós haveis de aceitar, e peço-Vos que continuais a proteger-me e a guiar-me pelo caminho da salvação.", "theme": ["missa-acao-de-gracas"], "saints": []},
  {"id": "oracao-santissima-virgem-maria-acao", "title": "Oração à Santíssima Virgem Maria (Ação de Graças)", "content": "Ó Santíssima Virgem Maria, Mãe de Deus e minha Mãe,abei-Vos me apresentado ao vosso Filho Jesus na Santa Missa. Rogai por mim, para que eu possa viver em graça e alcançar a vida eterna.", "theme": ["missa-acao-de-gracas"], "saints": ["virgem-maria"]},
  {"id": "oracao-a-sao-jose-acao", "title": "Oração a São José (Ação de Graças)", "content": "São José, guardião de Jesus e da Virgem Maria, proteged a minha alma e o meu corpo. Rogai por mim para que eu possa vivir santamente e alcançar o céu.", "theme": ["missa-acao-de-gracas"], "saints": ["sao-jose"]},
  {"id": "oferecimento-de-si-mesmo", "title": "Oferecimento de Si Mesmo", "content": "Senhor Jesus, ofereço-Vos todas as minhas ações, trabalhos e sofrimentos de hoje, pela glória de Deus, pela salvação das almas e em desagravo pelos meus pecados.", "theme": ["missa-acao-de-gracas"], "saints": []},
  {"id": "oracao-sao-francisco", "title": "Oração de São Francisco", "content": "Ó Deus, que fizestes de São Francisco um espejo de pobreza e humildade, concedei-me que, seguindo o seu exemplo, walk in vossa presença com coração puro e simples.", "theme": ["missa-acao-de-gracas"], "saints": ["sao-francisco"]},
  {"id": "oracao-a-sao-paulo", "title": "Oração a São Paulo", "content": "São Paulo, apóstolo de Cristo, que tanto trabalhastes pela propagação da fé, rogai por mim para que eu possa ser um bom católico eSpread a boa doutrina.", "theme": ["missa-acao-de-gracas"], "saints": ["sao-paulo"]},
  {"id": "oracao-aos-pastores-de-fatima", "title": "Oração aos Pastores de Fátima", "content": "São Francisco e Santa Jacinta, pastorinhos de Fátima, que vissteis a Virgem Maria e spreads as suas mensagens, rogai por mim e por todos os fiéis.", "theme": ["missa-acao-de-gracas"], "saints": []},
  {"id": "oracao-santissima-trindade-acao", "title": "Oração à Santíssima Trindade", "content": "Ó Santíssima Trindade, Pai, Filho e Espírito Santo, infinitamente bom e perfeito, eu Vos adoro e amo com todo o meu coração. Graças Vos dou por todos os benefícios que recebi de vossa mão.", "theme": ["missa-acao-de-gracas"], "saints": []},
  {"id": "eis-me-aqui", "title": "Eis-me Aqui", "content": "Senhor, eis-me aqui para cumprir a vossa vontade, com fidelidade no ordinário. Fazei que eu ofereça cada momento do meu dia como sacrifício de amor.", "theme": ["missa-acao-de-gracas"], "saints": []},
  {"id": "cântico-dos-três-jovens", "title": "Cântico dos Três Jovens", "content": "Bendizei, obras do Senhor, ao Senhor, louvai-O e exaltai-O para sempre. Anjos do Senhor, bendizei ao Senhor. Céus, bendizei ao Senhor. Águas todas que estais sobre os céus, bendizei ao Senhor. Sol e lua, bendizei ao Senhor. Estrelas do céu, bendizei ao Senhor.", "theme": ["missa-acao-de-gracas"], "saints": []},
  {"id": "para-o-trabalho", "title": "Para o Trabalho", "content": "São José, varão feliz, que tivestes a dita de ver e ouvir o próprio Deus, a quem muitos reis quiseram ver e não viram, ouvir e não ouviram; e não só ver e ouvir, mas ainda trazê-lo em vossos braços, beijá-lo, vesti-lo e guardá-lo! Rogai por nós, bem-aventurado São José, para que sirvamos a Deus com coração limpo e boas obras.", "theme": ["sao-jose", "trabalho"], "saints": ["sao-jose"]},
  {"id": "ave-jose", "title": "Ave José", "content": "Ave José, bendito entre todos os esposos, guarda de Virgens, pai putativo do Salvador, que fostes escolhido por Deus para ser o guardião de Jesus e de Maria, rogai por nós.", "theme": ["sao-jose"], "saints": ["sao-jose"]},
  {"id": "oracao-ao-anjo-da-guarda", "title": "Oração ao Anjo da Guarda", "content": "Santo Anjo do Senhor, meu zeloso guardador, pois que a ti me confiou a Piedade divina, hoje e sempre me governa, rege, guarda e ilumina. Amém.", "theme": ["diversos", "protecao"], "saints": ["anjos"]},
  {"id": "oracao-para-boa-morte", "title": "Oração para obter uma Boa Morte", "content": "Ó meu Deus, quando chegar a minha última hora, dai-me a graça de morrer em vossa graça, com a mente清醒 e o coração cheio de confiança em vossa misericórdia. Que eu possa receber os últimos sacramentos e partir em paz.", "theme": ["diversos"], "saints": []},
  {"id": "aceitacao-da-morte", "title": "Aceitação da Morte", "content": "Ó Deus, ensinai-me a aceitar a morte como passagem para a vida eterna. Que eu a receba com resignação e confiança, oferecendo-a em união com a paixão de Cristo.", "theme": ["diversos"], "saints": []},
  {"id": "oracao-momento-da-morte", "title": "Oração para o Momento da Morte", "content": "Jesus, meu Redentor, que morrestes na Cruz por mim, tendes piedade de mim no momento da minha morte. Mãe Maria, estai comigo. Santos Anjos, recebam a minha alma.", "theme": ["diversos"], "saints": []},
  {"id": "oracao-a-sagrada-familia", "title": "Oração à Sagrada Família", "content": "Ó Sagrada Família de Nazaré, exemplo de amor, de paz e de santidade, ensinai-me a viver em harmonia com os meus, a praticar a virtues da paciência e da compreensão.", "theme": ["diversos", "familia"], "saints": []},
  {"id": "consagracao-sagrado-coracao", "title": "Consagração ao Sagrado Coração de Jesus", "content": "Ó Sagrado Coração de Jesus, que tanto amastes a humanidade ao ponto de Vos entregar completamente na Cruz, eu me consagro ao vosso Corazóne. Receivei-me como filho e guardai-me.", "theme": ["diversos"], "saints": []},
  {"id": "ubi-caritas", "title": "Ubi Cáritas", "content": "Ubi cáritas et amor, Deus ibi est. Congregavit nos in unum Christi amor. Exsultemus et in ipso iucundemur. Timeamus et amemus Deum vivum. Et ex corde diligamus nos sincero.", "theme": ["devocoes"], "saints": []},
  {"id": "salmo-22", "title": "Salmo 22", "content": "O Senhor é meu pastor: nada me faltará. Deitar-me faz em verdes pastos, junto a águas de descanso me conduz. Restaura a minha alma, guia-me pelas sendas da justiça, por amor do seu nome. Ainda que eu walk no vale da morte, não temerei mal algum, porque Vós estais comigo.", "theme": ["devocoes"], "saints": []},
  {"id": "salmo-50", "title": "Salmo 50", "content": "Tende piedade de mim, ó Deus, segundo a vossa misericórdia; apagai a minha iniiquidade segundo a multidão das vossas compaixões. Lavai-me completamente da minha culpa e purificai-me do meu pecado.", "theme": ["devocoes"], "saints": []},
  {"id": "bencao-dos-alimentos", "title": "Benção dos Alimentos", "content": "Ó Deus, que criastes todos os alimentos para sustentaçao do corpo humano, abençoai + estes alimentos que vamos receber, para que nos deem saúde e forças para Vos servir.", "theme": ["devocoes"], "saints": []},
  {"id": "oracao-sao-josemaria", "title": "Oração a São Josemaria", "content": "Deus, que enchestes São Josemaria de graças para servir a Igreja, concedei-me viver santamente no trabalho de cada dia, oferecendo a Vós todas as minhas ações.", "theme": ["devocoes"], "saints": ["sao-josemaria"]},
  {"id": "antes-da-oracao-mental", "title": "Antes da Oração Mental", "content": "Ó meu Deus, venho fazer oração mental em vossa presença. Iluminai o meu entendimento para que eu possa compreender as verdades eternas e aquecer o meu coração no vosso amor.", "theme": ["devocoes"], "saints": []},
  {"id": "depois-da-oracao-mental", "title": "Depois da Oração Mental", "content": "Ó meu Deus, grazas Vos dou pela graça da oração. Fazei que o que aprendi na oração se transforme em obras concretas na minha vida.", "theme": ["devocoes"], "saints": []},
  {"id": "responso-portugues", "title": "Responso (Português)", "content": "Eterno Pai, pelas chagas de Jesus Cristo, concedei o descanso eterno às almas dos fiéis defuntos, especialmente às que mais precisam de vossa misericórdia. Que descansem em paz. Amém.", "theme": ["defuntos"], "saints": []},
  {"id": "responso-latim", "title": "Responso (Latim)", "content": "Requiem æternam dona eis, Domine, et lux perpetua luceat eis. Requiescant in pace. Amen. Deus, cui proprium est misereri semper et parcere, propitius esto animabus illorum, ut perintercessionem Sanctissimorum omnium Sanctorum tuorum a peccatorum suorum omnibus absoluti, beatæ quondam claritatis in conspectu tuo resident.", "theme": ["defuntos"], "saints": []},
  {"id": "responosrium-ii", "title": "Responsórium II", "content": "Libera me, Domine, de morte æterna in die illa tremenda, quando cæli movendi sunt et terra, quando venies iudicare sæculum per ignem. Tremens factus sum ego et timeo, dum discussio venerit atque ventura ira.", "theme": ["defuntos"], "saints": []}
]
```

**Step 2: Verify JSON is valid**

Run: `python3 -c "import json; json.load(open('iacula_app/assets/seed/prayers/pt-br/oracoes_catalog.json'))" && echo "Valid JSON"`

**Step 3: Commit**

```bash
git add iacula_app/assets/seed/prayers/pt-br/oracoes_catalog.json
git commit -m "feat(prayers): add complete prayer catalog (~80 prayers)"
```

---

## Task 2: Create Individual Prayer JSON Files

### Task 2a: Create Anjo do Senhor (with Angelus/Regina Caeli variants)

**Files:**
- Create: `iacula_app/assets/seed/prayers/pt-br/anjo-do-senhor.json`

**Step 1: Write the JSON file**

```json
{
  "regular": {
    "title": "Anjo do Senhor",
    "verses": [
      {"verse": "O anjo do Senhor anunciou a Maria.", "response": "E Ela concebeu do Espírito Santo."},
      {"verse": "Eis aqui a escrava do Senhor.", "response": "Faça-se em mim segundo a vossa palavra."},
      {"verse": "E o Verbo divino se fez carne.", "response": "E habitou entre nós."},
      {"verse": "Rogai por nós Santa Mãe de Deus.", "response": "Para que sejamos dignos das promessas de Cristo."}
    ],
    "prayer": "Oremos. Infundi, Senhor, nós Vos pedimos, em nossas almas a vossa graça, para que nós, que conhecemos pela Anunciação do Anjo a Encarnação de Jesus Cristo, vosso Filho, cheguemos por sua Paixão e sua Cruz à glória da Ressurreição. Pelo mesmo Jesus Cristo, Senhor nosso. Amém."
  },
  "easter": {
    "title": "Regina Caeli",
    "verses": [
      {"verse": "Rainha do Céu, alegrai-Vos, aleluia.", "response": "Porque quem merecestes trazer em vosso seio, aleluia."},
      {"verse": "Ressuscitou como disse, aleluia.", "response": "Rogai a Deus por nós, aleluia."},
      {"verse": "Exultai e alegrai-vos, ó Virgem Maria, aleluia.", "response": "Porque o Senhor ressuscitou verdadeiramente, aleluia."}
    ],
    "prayer": "Oremos. Ó Deus, que Vos dignastes alegrar o mundo com a Ressurreição do Vosso Filho Jesus Cristo, Senhor Nosso, concedei-nos, Vos suplicamos, que por sua Mãe, a Virgem Maria, alcancemos as alegrias da vida eterna. Por Cristo, Senhor Nosso. Amém."
  },
  "latin": {
    "title": "Angelus / Regina Caeli",
    "regular": {
      "title": "Angelus",
      "verses": [
        {"verse": "Angelus Dómini nuntiávit Maríæ.", "response": "Et concépit de Spíritu Sancto."},
        {"verse": "Ecce ancílla Dómini.", "response": "Fiat mihi secúndum verbum tuum."},
        {"verse": "Et Verbum caro factum est.", "response": "Et habitavit in nobis."},
        {"verse": "Ora pro nobis, sancta Dei Génetríx.", "response": "Ut digni efficiámur promissionibus Christi."}
      ],
      "prayer": "Oremus. Grátiam tuam, quæsumus, Dómine, méntibus nostris infúnde: ut qui, Angelo nuntiánte, Christi Filii tui incarnatiónem cognóvimus, per passiónem eius et crucem ad resurrectiónis glóriam perducámur. Per eumdem Christum Dóminum nostrum. Amen."
    },
    "easter": {
      "title": "Regina Caeli",
      "verses": [
        {"verse": "Regína cæli, lætáre, allelúia.", "response": "Quia quem meruísti portáre, allelúia."},
        {"verse": "Resurréxit, sicut dixit, allelúia.", "response": "Ora pro nobis Deum, allelúia."},
        {"verse": "Gaude et lætáre, Virgo Maria, allelúia.", "response": "Quia surréxit Dóminus vere, allelúia."}
      ],
      "prayer": "Orémus. Deus, qui per resurrectiónem Fílii tui, Dómini nostri Iesu Christi, mundum lætífícáre dignátus es: præsta, quæsumus, ut, per eius Genetrícem Vírginem Maríam, perpétuæ capiámus gáudia vitæ. Per eúmdem Christum Dóminum nostrum. Amen."
    }
  }
}
```

**Step 2: Commit**

```bash
git add iacula_app/assets/seed/prayers/pt-br/anjo-do-senhor.json
git commit -m "feat(prayers): add Anjo do Senhor with PT/LAT variants"
```

### Task 2b: Update Angelus.json with Latin

**Files:**
- Modify: `iacula_app/assets/seed/prayers/pt-br/angelus.json`

**Step 1: Replace content**

```json
{
  "regular": {
    "title": "Angelus",
    "verses": [
      {"verse": "O anjo do Senhor anunciou a Maria.", "response": "E Ela concebeu do Espírito Santo."},
      {"verse": "Eis aqui a escrava do Senhor.", "response": "Faça-se em mim segundo a vossa palavra."},
      {"verse": "E o Verbo divino se fez carne.", "response": "E habitou entre nós."},
      {"verse": "Rogai por nós Santa Mãe de Deus.", "response": "Para que sejamos dignos das promessas de Cristo."}
    ],
    "prayer": "Oremos. Infundi, Senhor, nós Vos pedimos, em nossas almas a vossa graça, para que nós, que conhecemos pela Anunciação do Anjo a Encarnação de Jesus Cristo, vosso Filho, cheguemos por sua Paixão e sua Cruz à glória da Ressurreição. Pelo mesmo Jesus Cristo, Senhor nosso. Amém."
  },
  "easter": {
    "title": "Regina Caeli",
    "verses": [
      {"verse": "Rainna do Céu, alegrai-Vos, aleluia.", "response": "Porque quem merecestes trazer em vosso seio, aleluia."},
      {"verse": "Ressuscitou como disse, aleluia.", "response": "Rogai a Deus por nós, aleluia."},
      {"verse": "Exultai e alegrai-vos, ó Virgem Maria, aleluia.", "response": "Porque o Senhor ressuscitou verdadeiramente, aleluia."}
    ],
    "prayer": "Oremos. Ó Deus, que Vos dignastes alegrar o mundo com a Ressurreição do Vosso Filho Jesus Cristo, Senhor Nosso, concedei-nos, Vos suplicamos, que por sua Mãe, a Virgem Maria, alcancemos as alegrias da vida eterna. Por Cristo, Senhor Nosso. Amém."
  },
  "latin": {
    "title": "Angelus / Regina Caeli",
    "regular": {
      "title": "Angelus",
      "verses": [
        {"verse": "Angelus Dómini nuntiávit Maríæ.", "response": "Et concépit de Spíritu Sancto."},
        {"verse": "Ecce ancílla Dómini.", "response": "Fiat mihi secúndum verbum tuum."},
        {"verse": "Et Verbum caro factum est.", "response": "Et habitavit in nobis."},
        {"verse": "Ora pro nobis, sancta Dei Génetríx.", "response": "Ut digni efficiámur promissionibus Christi."}
      ],
      "prayer": "Oremus. Grátiam tuam, quæsumus, Dómine, méntibus nostris infúnde: ut qui, Angelo nuntiánte, Christi Filii tui incarnatiónem cognóvimus, per passiónem eius et crucem ad resurrectiónis glóriam perducámur. Per eumdem Christum Dóminum nostrum. Amen."
    },
    "easter": {
      "title": "Regina Caeli",
      "verses": [
        {"verse": "Regína cæli, lætáre, allelúia.", "response": "Quia quem meruísti portáre, allelúia."},
        {"verse": "Resurréxit, sicut dixit, allelúia.", "response": "Ora pro nobis Deum, allelúia."},
        {"verse": "Gaude et lætáre, Virgo Maria, allelúia.", "response": "Quia surréxit Dóminus vere, allelúia."}
      ],
      "prayer": "Orémus. Deus, qui per resurrectiónem Fílii tui, Dómini nostri Iesu Christi, mundum lætífícáre dignátus es: præsta, quæsumus, ut, per eius Genetrícem Vírginem Maríam, perpétuæ capiámus gáudia vitæ. Per eúmdem Christum Dóminum nostrum. Amen."
    }
  }
}
```

**Step 2: Commit**

```bash
git add iacula_app/assets/seed/prayers/pt-br/angelus.json
git commit -m "feat(prayers): update Angelus with Latin variants"
```

### Task 2c: Create Eucaristic Prayers (visita-santissimo, adoro-te-devote, pange-lingua)

**Files:**
- Create: `iacula_app/assets/seed/prayers/pt-br/visita-santissimo.json`
- Create: `iacula_app/assets/seed/prayers/pt-br/adoro-te-devote.json`
- Create: `iacula_app/assets/seed/prayers/pt-br/pange-lingua.json`

**Step 1: Create visita-santissimo.json**

```json
{
  "portuguese": {
    "title": "Visita ao Santíssimo",
    "content": "V/. Graças e louvores sejam dados a todo momento. R/. Ao santíssimo e diviníssimo Sacramento.\n\nPai-Nosso, Ave-Maria e Glória.\n\nComunhão espiritual: Eu quisera, Senhor, receber-vos com aquela pureza, humildade e devoção com que vos recebeu a vossa Santíssima Mãe, com o espírito e o fervor dos Santos."
  },
  "latin": {
    "title": "Visit to the Blessed Sacrament",
    "content": "V/. Adoremus in æternum Sanctíssimum Sacramentum. R/. Adoremus in æternum Sanctíssimum Sacramentum.\n\nPater noster, qui es in cœlis: sanctificetur nomen tuum; advéniat regimen tuum; fiat voluntas tua, sicut in cœlo, et in terra. Panem nostrum cotidianum da nobis hódie; et dimitte nobis débita nostra, sicut et nos dimíttimus debitóribus nostris; et ne nos inducas in tentatiónem; sed líbera nos a malo. Amen.\n\nAve Maria, grátia plena, Dóminus tecum: benedicta tu in muliéribus et benedictus fructus ventris tui Iesus. Sancta Maria, Mater Dei, ora pro nobis peccatóribus, nunc et in hora mortis nostræ. Amen.\n\nGlória Patri et Fílio et Spirítui Sancto, sicut erat in princípio et nunc et semper et in sæcula sæculorum. Amen.\n\nComunhão espiritual: Eu quisera, Senhor, receber-vos com aquela pureza, humildade e devoção com que vos recebeu a vossa Santíssima Mãe, com o espírito e o fervor dos Santos."
  }
}
```

**Step 2: Create adoro-te-devote.json**

```json
{
  "portuguese": {
    "title": "Adoro te Devote",
    "content": "Adoro-Vos com devoção, Deus escondido,\nQue sob estas aparências estais presente.\nA Vós se submete meu coração por inteiro,\nE ao contemplar-Vos se rende totalmente.\n\nA vista, o tato, o gosto sobre Vós se enganam,\nMas basta o ouvido para crer com firmeza.\nCreio em tudo o que disse o Filho de Deus;\nNada mais verdadeiro que esta palavra de verdade.\n\nNa Cruz estava oculta a divindade,\nMas aqui se esconde também a humanidade;\nCreio, porém, e confesso uma e outra,\nE peço o que pediu o ladrão arrependido.\n\nNão as chagas, como Tomé as viu,\nMas confesso que sois o meu Deus.\nFazei que eu creia mais e mais em Vós,\nQue em Vós espere, que Vos ame.\n\nÓ memorial da morte do Senhor!\nÓ Pão vivo que dais a vida ao homem!\nQue a minha alma sempre de Vós viva,\nQue sempre lhe seja doce o vosso sabor.\n\nBom pelicano, Senhor Jesus!\nLimpai-me a mim, imundo, com o vosso Sangue,\nSangue do qual uma só gota\nPode salvar o mundo inteiro.\n\nJesus, a quem agora contemplo escondido,\nRogo-Vos se cumpra o que tanto desejo:\nQue, ao contemplar-Vos face a-face,\nSeja eu feliz vendo a vossa glória. Amém."
  },
  "latin": {
    "title": "Adóro te Devote",
    "content": "Adóro Te devóte, latens Déitas,\nQuæ sub his figúris vere látitas.\nTibi se cor meum totum súbiicit,\nQuia Te contémplans totum déficit.\n\nVisus, tactus, gustus in te fállitur;\nSed audítu solo tuto créditur;\nCredo quidquid dixit Dei Fílius;\nNil hoc verbo veritátis vérius.\n\nIn cruce latébat sola Déitas;\nAt hic latet simul et humánitas;\nAmbo tamen credens atquecónfitens,\nPeto quod petívit latro poenitens.\n\nPlagas, sicut Thomas, non intúeor,\nDeum tamen meum te confíteor;\nFac me tibi semper magis crédere,\nIn te spem habére, Te dilígere.\n\nO memoriále mortis Dómine!\nPanis vivus vitam præstans hómini;\nPræsta meæ menti de Te vívere,\nEt Te illi semper dulce sápere.\n\nPie pellicáne, Iesu Dómini!\nMe immúndum munda tuo sánguine:\nCuius una stilla salvum fácere\nTotum mundum quit ab omni scélere.\n\nIesu, quem velátum nunc aspício,\nOro, fiat illud quod tamítio;\nUt Te reveláta cernens fácie,\nVisu sim beátus tuæ glóriæ. Amen."
  }
}
```

**Step 3: Create pange-lingua.json**

```json
{
  "portuguese": {
    "title": "Pange Lingua",
    "content": "Celebremos o mistério\nDa divina Eucaristia,\nCorpo e Sangue de Jesus:\nO mistério do Deus vivo,\nTão real no seu altar\nComo outrora sobre a Cruz.\n\nVeneremos, adoremos\nA presença do senhor,\nNossa Luz e Pão da Vida.\nCante a alma o seu louvor.\nAdoremos no sacrário\nDeus oculto por amor.\n\nDemos glória ao Pai do Céu,\nInfinita Majestade,\nGlória ao Filho e ao Espírito Santo.\nEm espírito e verdade,\nVeneremos, adoremos\nA Santíssima Trindade.\n\nV/. Vós sois o Pão que desceu dos Céus.\nR/. Para dar vida ao mundo.\n\nOremos. Deus, que neste admirável sacramento nos deixastes o memorial da vossa Paixão, dai-nos venerar com tão grande amor o mistério do vosso Corpo e do vosso Sangue, que possamos colher continuamente os frutos da vossa Redenção. Vós que viveis e reinais pelos séculos dos séculos. R/. Amém."
  },
  "latin": {
    "title": "Pange Lingua",
    "content": "Pange língua gloriósi\nCórporis mystérium,\nSanguinísque pretiósi,\nquem in mundi prétium\nfructus ventris generósi,\nRex effúdit géntium.\n\nTantum ergo Sacraméntum\nvenerémus cérnui:\net antíquum documéntum\nnovo cedat rítui:\npraestet fides suppleméntum\nsénsuum deféctui.\n\nGenitóri, Genitóque\nlaus et iubilátio,\nsalus, honor, virtus quoque\nsit et benedíctio;\nProcedénti ab utróque\ncompar sit laudátio. Amen.\n\nV/. Pánem de caélo praestitísti eis.\nR/. Omne delectaméntum in se habéntem.\n\nOrémus. Deus, qui nobis sub Sacraménto mirábili Passiónis tuae memóriam reliquísti; tríbue, quaésumus, ita nos Córporis et Sánguinis tui sacra mystéria venerári; ut redemptiónis tuae fructum in nobis júgiter sentiámus. Qui vivis et regnas in saécula saeculórum. R/. Amen."
  }
}
```

**Step 4: Commit**

```bash
git add iacula_app/assets/seed/prayers/pt-br/visita-santissimo.json iacula_app/assets/seed/prayers/pt-br/adoro-te-devote.json iacula_app/assets/seed/prayers/pt-br/pange-lingua.json
git commit -m "feat(prayers): add Eucaristic prayers with PT/LAT versions"
```

### Task 2d: Create Espírito Santo Prayers

**Files:**
- Create: `iacula_app/assets/seed/prayers/pt-br/veni-creator.json`
- Create: `iacula_app/assets/seed/prayers/pt-br/veni-sancte-spiritus.json`

**Step 1: Create veni-creator.json**

```json
{
  "portuguese": {
    "title": "Vinde, Espírito Criador",
    "content": "Vinde, Espírito Criador,\nVisitai a alma dos vossos fiéis;\nEnchei de graça celestial\nOs corações que Vós criastes.\n\nVós, chamado o Consolador,\nDom do Deus altíssimo,\nFonte viva, fogo, caridade\ne unção espiritual.\n\nVós, com vossos sete dons,\nSois força da destra de Deus,\nVós, o prometido pelo Pai;\nA vossa palavra enriquece nossos lábios.\n\nAcendei a vossa luz em nossas almas,\nInfundi vosso amor em nossos peitos;\nE a fraqueza da nossa carne,\nFortalecei-a com redobrada força.\n\nO inimigo, afugentai-o bem para longe;\nDai-nos a paz quanto antes;\nAbrindo-nos caminho como guia,\nVenceremos todos os perigos.\n\nQue por Vós conheçamos o Pai,\nConheçamos igualmente o Filho,\nE em Vós, Espírito de ambos,\nCreiamos todo o tempo.\n\nV/. Enviai o vosso Espírito e tudo será criado.\nR/. E renovareis a face da terra.\n\nOremos: Ó Deus, que iluminastes os corações dos vossos fiéis com a luz do Espírito Santo, fazei-nos dóceis ao vosso Espírito para que saboreemos sempre o bem e gozemos de suas consolações. Por Jesus Cristo Senhor Nosso. Amém."
  },
  "latin": {
    "title": "Veni Creator",
    "content": "Veni, creátor Spíritus\nmentes tuórum vísita,\nimple supérna grátia,\nquæ tu creásti, péctora.\n\nQui díceris Paráclitus,\naltíssimum donum Dei,\nfons vivus, ignis, cáritas\net spiritális únctio.\n\nTu septifórmis múnere,\ndigitus patérnæ déxteræ,\ntu rite promíssum Patris\nsermóne ditans gúttura.\n\nAccénde lumen sénsibus,\ninfúnde amórem córdibus,\ninfírma nostri córporis\nvirtúte firmans pérpeti.\n\nHostem repéllas lóngius\npacémque dones prótinus;\ndúctore sic te prævio,\nvitémus omne nóxium.\n\nPer te sciámus da Patrem\nnoscámus atque Fílium,\nteque utriúsque Spíritum\ncredámus omni témpore.\n\nDeo Patri sit glória,\net Fílio, qui a mórtuis\nsurréxit, ac Paráclito,\nin sæculórum sæcula. Amen.\n\nV/. Emítte Spíritum tuum et creabúntur.\nR/. Et renovábis fáciem terræ.\n\nOremus: Deus, qui corda fidélium Sancti Spíritus illustratióne docuísti, da nóbis in eódem Spíritu recta sápere, et de eius semper consolatióne gaudére. Per Christum Dóminum Nostrum. Amen."
  }
}
```

**Step 2: Create veni-sancte-spiritus.json**

```json
{
  "portuguese": {
    "title": "Vinde Santo Espírito",
    "content": "Vinde Santo Espírito\ne do céu mandai\nLuminoso raio.\nVinde pai dos pobres\nDoador dos dons\nLuz dos corações.\n\nGrande defensor\nEm nós habitais\nE nos confortais.\nNa fadiga, pouso,\nNo ardor, brandura\nE na dor, ternura.\n\nÓ luz venturosa,\nQue vossos clarões\nEncham os corações.\nSem vosso poder\nEm qualquer vivente\nNada há de inocente.\n\nLavai o impuro\nE regai o seco,\nCurai o enfermo.\nDobrai a dureza,\nAquecei o frio,\nLivrai do desvio.\n\nAos vossos fiéis\nQue oram com vibrantes sons\nDai os sete dons.\nDai virtude e prêmio\nE no fim dos dias\nEterna alegria.\nAmém."
  },
  "latin": {
    "title": "Veni, Sancte Spiritus",
    "content": "Veni, Sancte Spíritus,\nEt emítte coelitus\nLucis tuæ rádium.\nVeni, Pater páuperum,\nVeni, Dator múnerum,\nVeni, Lumen córdium.\n\nConsolátor óptime,\nDulcis hospes ánimæ,\nDulce refrigérium.\nIn labóre réquies,\nIn æstu tempéries,\nIn fletu solátium.\n\nO lux beatíssima,\nReple cordis íntima\nTuórum fidélium.\nSine tuo númine,\nNihil est in hómine,\nNihil est innóxium.\n\nLava quod est sórdidum,\nRiga quod est áridum,\nSana quod est sáucium.\nFlecte quod est rígidum,\nFove quod est frígidum,\nRege quod est dévium.\n\nDa tuis fidélibus\nIn te confidéntibus\nSacrum septenárium.\nDa virtútis méritum,\nDa salútis exitsum,\nDa perénne gáudium. Amen."
  }
}
```

**Step 3: Commit**

```bash
git add iacula_app/assets/seed/prayers/pt-br/veni-creator.json iacula_app/assets/seed/prayers/pt-br/veni-sancte-spiritus.json
git commit -m "feat(prayers): add Espírito Santo prayers with PT/LAT"
```

### Task 2e: Create São José Prayers

**Files:**
- Create: `iacula_app/assets/seed/prayers/pt-br/sao-jose.json`

**Step 1: Create sao-jose.json**

```json
{
  "title": "Orações a São José",
  "prayers": [
    {
      "id": "para-o-trabalho",
      "title": "Para o Trabalho",
      "content": "São José, varão feliz, que tivestes a dita de ver e ouvir o próprio Deus, a quem muitos reis quiseram ver e não viram, ouvir e não ouviram; e não só ver e ouvir, mas ainda trazê-lo em vossos braços, beijá-lo, vesti-lo e guardá-lo!\n\nRogai por nós, bem-aventurado São José.\nPara que sejamos dignos das promessas de Cristo.\n\nOremos: Ó Deus, que nos concedestes o sacerdócio real, nós Vos pedimos que, assim como São José mereceu cuidar e trazer em seus braços com carinho o vosso Filho unigênito, nascido da Virgem Maria, façais que nós Vos sirvamos com coração limpo e boas obras, de modo que hoje recebamos dignamente o sacrossanto Corpo e Sangue do vosso Filho, e na vida futura mereçamos alcançar o prêmio eterno. Amém."
    },
    {
      "id": "ave-jose",
      "title": "Ave José",
      "content": "Ave José, bendito entre todos os esposos,\nGuarda de Virgens, pai putativo do Salvador,\nQue fostes escolhido por Deus para ser o guardião de Jesus e de Maria,\nRogai por nós.\n\nRogai por nós, bem-aventurado São José.\nPara que sejamos dignos das promessas de Cristo."
    }
  ]
}
```

**Step 2: Commit**

```bash
git add iacula_app/assets/seed/prayers/pt-br/sao-jose.json
git commit -m "feat(prayers): add São José prayers"
```

### Task 2f: Create Defuntos Prayers

**Files:**
- Create: `iacula_app/assets/seed/prayers/pt-br/defuntos.json`

**Step 1: Create defuntos.json**

```json
{
  "title": "Orações pelos Defuntos",
  "prayers": [
    {
      "id": "responso-portugues",
      "title": "Responso (Português)",
      "content": "Eterno Pai, pelas chagas de Jesus Cristo, concedei o descanso eterno às almas dos fiéis defuntos, especialmente às que mais precisam de vossa misericórdia.\n\nQue elles descansem em paz. Amém.\n\nV/. Da-lhes, Senhor, o eterno repouso.\nR/. E a luz perpétua brilhe para eles.\n\nV/. Que descansem em paz.\nR/. Amém.\n\nV/. Dai-lhes, Senhor, o eterno repouso.\nR/. E a luz perpétua brilhe para eles."
    },
    {
      "id": "responso-latim",
      "title": "Responso (Latim)",
      "content": "Requiem æternam dona eis, Domine,\net lux perpetua luceat eis.\n\nRequiescant in pace. Amen.\n\nV/. Requiem æternam dona eis, Domine.\nR/. Et lux perpetua luceat eis.\n\nV/. Requiescant in pace.\nR/. Amen.\n\nDeus, cui proprium est misereri semper et parcere, propitius esto animabus illorum, ut per intercessionem Sanctissimorum omnium Sanctorum tuorum a peccatorum suorum omnibus absoluti, beatæ quondam claritatis in conspectu tuo resident."
    },
    {
      "id": "responorium-ii",
      "title": "Responsórium II",
      "content": "Libera me, Domine, de morte æterna\nIn die illa tremenda,\nQuando cæli movendi sunt et terra,\nQuando venies iudicare sæculum per ignem.\n\nTremens factus sum ego et timeo,\nDum discussio venerit atque ventura ira.\n\nDies illa, dies iræ,\nCalamitatis et miseriæ,\nDies magna et amara valde.\n\nLibera me, Domine, de morte æterna."
    }
  ]
}
```

**Step 2: Commit**

```bash
git add iacula_app/assets/seed/prayers/pt-br/defuntos.json
git commit -m "feat(prayers): add Defuntos prayers"
```

### Task 2g: Create Rosário Files

**Files:**
- Create: `iacula_app/assets/seed/prayers/pt-br/rosario-pt.json`
- Create: `iacula_app/assets/seed/prayers/pt-br/rosario-la.json`

**Step 1: Create rosario-pt.json** (abbreviated - full content from PDF)

```json
{
  "title": "Santo Rosário (Português)",
  "visita": {
    "title": "Visita ao Santíssimo",
    "content": "V/. Graças e louvores sejam dados a todo momento. R/. Ao santíssimo e diviníssimo Sacramento.\n\nPai nosso que estais nos céus, santificado seja o vosso nome; venha a nós o vosso reino, seja feita a vossa vontade assim na terra como no céu.\n\nAve, Maria, cheia de graça, o Senhor é convosco, bendita sois vós entre as mulheres e bendito é o fruto do vosso ventre, Jesus.\n\nGlória ao Pai, ao Filho e ao Espírito Santo. Como era no princípio, agora e sempre. Amém."
  },
  "mysteries": {
    "gozosos": {
      "title": "Mistérios Gozosos (segunda-feira e sábado)",
      "items": [
        {"mystery": "A Anunciação", "padrinho": "O anjo Gabriel announció a Maria"},
        {"mystery": "A Visitação", "padrinho": "Maria visitou Santa Isabel"},
        {"mystery": "O Nascimento", "padrinho": "Jesus nasceu em Belém"},
        {"mystery": "A Purificação", "padrinho": "Maria e José apresentaram Jesus no Templo"},
        {"mystery": "O Menino no Templo", "padrinho": "Jesus foi achado no Templo"}
      ]
    },
    "luminosos": {
      "title": "Mistérios Luminosos (quinta-feira)",
      "items": [
        {"mystery": "O Batismo", "padrinho": "Jesus foi batizado no Jordão"},
        {"mystery": "As Bodas de Caná", "padrinho": "Jesus transformou a água em vinho"},
        {"mystery": "O Anúncio do Reino", "padrinho": "Jesus anunciou o Reino de Deus"},
        {"mystery": "A Transfiguração", "padrinho": "Jesus se transfigurou no monte"},
        {"mystery": "A Eucaristia", "padrinho": "Jesus instituiu a Eucaristia"}
      ]
    },
    "dolorosos": {
      "title": "Mistérios Dolorosos (terça e sexta-feira)",
      "items": [
        {"mystery": "A Oração no Horto", "padrinho": "Jesus orou no Horto das Oliveiras"},
        {"mystery": "A Flagelação", "padrinho": "Jesus foi flagelado"},
        {"mystery": "A Coroação de Espinhos", "padrinho": "Jesus foi coroado de espinhos"},
        {"mystery": "A Cruz às Costas", "padrinho": "Jesus levou a Cruz ao Calvário"},
        {"mystery": "A Morte na Cruz", "padrinho": "Jesus morreu na Cruz"}
      ]
    },
    "gloriosos": {
      "title": "Mistérios Gloriosos (quarta-feira e domingo)",
      "items": [
        {"mystery": "A Ressurreição", "padrinho": "Jesus ressuscitou"},
        {"mystery": "A Ascensão", "padrinho": "Jesus subiu aos céus"},
        {"mystery": "A Vinda do Espírito Santo", "padrinho": "O Espírito Santo desceu"},
        {"mystery": "A Assunção", "padrinho": "Maria foi assunta aos céus"},
        {"mystery": "A Coroação", "padrinho": "Maria foi coroada Rainha"}
      ]
    }
  },
  "ladainha": {
    "title": "Ladainha a Nossa Senhora",
    "invocations": [
      {"call": "Santa Maria", "response": "Rogai por nós"},
      {"call": "Santa Mãe de Deus", "response": "Rogai por nós"},
      {"call": "Santa Virgem das virgens", "response": "Rogai por nós"},
      {"call": "Mãe de Jesus Cristo", "response": "Rogai por nós"},
      {"call": "Mãe da Igreja", "response": "Rogai por nós"},
      {"call": "Mãe da divina graça", "response": "Rogai por nós"},
      {"call": "Mãe puríssima", "response": "Rogai por nós"},
      {"call": "Mãe castíssima", "response": "Rogai por nós"},
      {"call": "Mãe imaculada", "response": "Rogai por nós"},
      {"call": "Mãe intacta", "response": "Rogai por nós"},
      {"call": "Mãe amável", "response": "Rogai por nós"},
      {"call": "Mãe admirável", "response": "Rogai por nós"},
      {"call": "Mãe do bom conselho", "response": "Rogai por nós"},
      {"call": "Mãe do Criador", "response": "Rogai por nós"},
      {"call": "Mãe do Salvador", "response": "Rogai por nós"},
      {"call": "Virgem prudentíssima", "response": "Rogai por nós"},
      {"call": "Virgem veneranda", "response": "Rogai por nós"},
      {"call": "Virgem digna de louvor", "response": "Rogai por nós"},
      {"call": "Virgem poderosa", "response": "Rogai por nós"},
      {"call": "Virgem clemente", "response": "Rogai por nós"},
      {"call": "Virgem fiel", "response": "Rogai por nós"},
      {"call": "Espelho da justiça", "response": "Rogai por nós"},
      {"call": "Sede da Sabedoria", "response": "Rogai por nós"},
      {"call": "Causa da nossa alegria", "response": "Rogai por nós"},
      {"call": "Rosa mística", "response": "Rogai por nós"},
      {"call": "Torre de Davi", "response": "Rogai por nós"},
      {"call": "Torre de marfim", "response": "Rogai por nós"},
      {"call": "Casa de ouro", "response": "Rogai por nós"},
      {"call": "Arca da aliança", "response": "Rogai por nós"},
      {"call": "Porta do céu", "response": "Rogai por nós"},
      {"call": "Estrela da manhã", "response": "Rogai por nós"},
      {"call": "Saúde dos enfermos", "response": "Rogai por nós"},
      {"call": "Refúgio dos pecadores", "response": "Rogai por nós"},
      {"call": "Consoladora dos aflitos", "response": "Rogai por nós"},
      {"call": "Auxílio dos cristianos", "response": "Rogai por nós"},
      {"call": "Rainha dos Anjos", "response": "Rogai por nós"},
      {"call": "Rainha dos Patriarcas", "response": "Rogai por nós"},
      {"call": "Rainha dos Profetas", "response": "Rogai por nós"},
      {"call": "Rainha dos Apóstolos", "response": "Rogai por nós"},
      {"call": "Rainha dos Mártires", "response": "Rogai por nós"},
      {"call": "Rainha dos Confessores", "response": "Rogai por nós"},
      {"call": "Rainha das Virgens", "response": "Rogai por nós"},
      {"call": "Rainha de todos os Santos", "response": "Rogai por nós"},
      {"call": "Rainha concebida sem pecado original", "response": "Rogai por nós"},
      {"call": "Rainha assumta aos céus", "response": "Rogai por nós"},
      {"call": "Rainha do Santíssimo Rosário", "response": "Rogai por nós"},
      {"call": "Rainha da Família", "response": "Rogai por nós"},
      {"call": "Rainha da Paz", "response": "Rogai por nós"}
    ]
  }
}
```

**Step 2: Create rosario-la.json** (Latin version with full Litaniæ Lauretanæ)

**Step 3: Commit**

```bash
git add iacula_app/assets/seed/prayers/pt-br/rosario-pt.json iacula_app/assets/seed/prayers/pt-br/rosario-la.json
git commit -m "feat(prayers): add Santo Rosário PT/LAT"
```

---

## Summary

**After completing all tasks:**
- All ~80 prayers from the PDF will be in the catalog
- Individual JSON files created for structured prayers (with verses)
- PT/LAT versions combined in same files where applicable
- Tests pass (run `flutter test` if available)

**Commands to verify:**
```bash
git log --oneline -20
```

Expected output should show commits for each prayer addition.
