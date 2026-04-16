# SumSum: Disseny matemàtic de nivells

## El problema actual

Els 70 nivells actuals segueixen un patró massa simple:

> "Aquí tens 3-4 nombres petits. Combina'ls per fer X."

La decisió matemàtica és trivial. El 95% del temps del jugador és construir
cintes, no pensar. El nivell "final" es resol en 5 segons de pensament.

## La visió

SumSum ha de ser un joc on el jugador **descomposa nombres complexos a partir
de fonts petites**. El repte és matemàtic: factoritzar, trobar camins, construir
arbres d'operacions. Les cintes són el mitjà, no el fi.

Referència: a Beltmatic, jugadors avançats construeixen nombres de 5-6 xifres
a partir de generadors de 1-9, usant factorització, potències de 10,
descomposició en base 64, diferències de quadrats, i sistemes binaris.
No cal arribar tan lluny, però sí moure'ns en aquesta direcció.

---

## Eixos de dificultat matemàtica

### Eix 1: Descomposició (pensar enrere)

El jugador rep fonts petites (2, 3, 5...) i un objectiu gran. Ha de
**descomposar el nombre objectiu** en operacions assolibles.

Exemples:

| Fonts | Objectiu | Descomposició | Operacions |
|-------|----------|---------------|:----------:|
| 2, 3 | 72 | 72 = 2^3 x 3^2 = 8 x 9 | 5 |
| 2, 5 | 100 | 2x5=10, 10x10=100 | 3 |
| 2, 3 | 54 | 54 = 2 x 3^3 = 2 x 27 | 4 |
| 2, 5 | 200 | 5x5=25, 2x2x2=8, 25x8=200 | 5 |
| 2, 3 | 144 | 144 = 12^2 = (2x2x3)^2 | 5+ |

Conceptes: factorització, potències, factors primers.

### Eix 2: Pipeline (cadena seqüencial)

El jugador construeix una **cadena llarga d'operacions** on cada resultat
alimenta la següent. El repte és planificar la seqüència.

Exemples:

| Fonts | Objectiu | Cadena | Ops |
|-------|----------|--------|:---:|
| 2, 3, 1 | 127 | 2x2=4, 4x2=8, 8x2=16, 16x2=32, 32x2=64, 64x2=128, 128-1=127 | 7 |
| 3, 7, 1 | 41 | 3x7=21, 21x2... no. 3+7=10, 10x... hmm. 7-3=4, 4x10+1=41 | 4+ |
| 2, 5, 3 | 97 | 2x5=10, 10x10=100, 100-3=97 | 3 |
| 2, 3 | 31 | 2^5=32, 32-1... no tenim 1. 2+3=5, 5x... 3x10+1=31 | varies |

Conceptes: ordre d'operacions, planificació, pensament seqüencial.

### Eix 3: Arbre de computació (paral·lelisme)

Múltiples branques independents que convergeixen en un resultat final.
El jugador ha de **planificar l'espai del grid** i la sincronització.

Exemples:

| Fonts | Objectiu | Arbre | Ops |
|-------|----------|-------|:---:|
| 2, 3 | 108 | Branca A: 2x2=4 / Branca B: 3x3x3=27 / Final: 4x27=108 | 5 |
| 2, 3, 5 | 150 | Branca A: 2x3=6 / Branca B: 5x5=25 / Final: 6x25=150 | 4 |
| 2, 3 | 1296 | 2x3=6, 6x6=36, 36x36=1296 (quadrat de quadrat!) | 4 |
| 2, 3 | 288 | 2^5=32, 3^2=9, 32x9=288 | 6 |

Conceptes: factorització en arbre, factors primers, gestió de l'espai.

### Eix 4: Nombres difícils (primers i especials)

Nombres primers no es poden factoritzar. Cal construir-los amb suma/resta
des d'un nombre proper que SÍ es pugui factoritzar. Això ensenya la diferència
entre primers i compostos de forma natural.

Exemples:

| Fonts | Objectiu | Estratègia |
|-------|----------|-----------|
| 2, 3 | 97 (primer) | 100-3 = (2x5)^2 - 3... no tenim 5. O: 3x33-2=97. 33=3x11. 11=? Difícil! |
| 2, 3, 1 | 127 (primer de Mersenne) | 2^7 - 1 = 128 - 1. Cadena de duplicació. |
| 2, 3, 1 | 61 (primer) | 64-3 = 2^6 - 3. O: 60+1 = (2x2x3x5)+1... cal construir 60 primer. |
| 2, 5, 1 | 251 (primer) | 250+1 = 2x5^3 + 1 = 2x125+1. Cal fer 5x5x5=125 |

Conceptes: nombres primers, Mersenne, pensament creatiu, residus.

---

## Estratègies matemàtiques (referència Beltmatic)

Jugadors de Beltmatic usen aquestes estratègies que SumSum pot aprofitar:

### 1. Potències de 10
Construir 10 (2x5 o 2+3+5) i usar-lo com a base.
Per fer 453: 450+3 = 9x50+3 = 9x5x10+3.

### 2. Descomposició per xifres
Per fer 67583: 6x10000 + 7x1000 + 5x100 + 8x10 + 3.
Requereix construir potències de 10 primer.

### 3. Factorització prima
Per fer 33559: 907 x 37 (tots dos primers). Difícil!
Alternativa: buscar descomposicions mixtes.

### 4. Diferència de quadrats
a^2 - b^2 = (a+b)(a-b). Per fer 31x41=1271:
36^2 - 5^2 = 1296 - 25 = 1271. 36 i 5 són fàcils de construir.

### 5. Sistema binari
Construir potències de 2 (2, 4, 8, 16, 32...) i sumar les necessàries.
Per fer 97: 64+32+1 = 97. Ensenya representació binària!

---

## Progressió proposada

### Fase 0: Tutorial (actual, 4 nivells)
Aprendre mecàniques del joc. Cap repte matemàtic.

### Fase 1: Operacions directes (actual, ~20 nivells)
Combinar 2-4 nombres amb 1-2 operacions. Per a cicle superior de primària.
Valor pedagògic: taules, propietats commutativa/associativa.

### Fase 2: Descomposició simple (NOU, ~10 nivells)
Fonts: 2-3 nombres petits. Objectius: 20-100. 3-5 operacions.
El jugador comença a pensar "enrere" per primera vegada.

Exemples de nivells:

| # | Fonts | Objectiu | Solució esperada | Concepte |
|---|-------|----------|-----------------|----------|
| 1 | 2, 5 | 50 | 2x5=10, 10x5=50 | Reusar font |
| 2 | 3, 4 | 48 | 3x4=12, 12x4=48 o 4x4=16, 16x3=48 | Múltiples camins |
| 3 | 2, 7 | 28 | 2x2=4, 4x7=28 o 7x2=14, 14x2=28 | Construir factor |
| 4 | 2, 3 | 36 | 2x2=4, 3x3=9, 4x9=36 | Arbre bàsic |
| 5 | 3, 5 | 75 | 3x5=15, 15x5=75 o 5x5=25, 25x3=75 | Dues vies |
| 6 | 2, 5 | 100 | 2x5=10, 10x10=100 | Autoalimentació |
| 7 | 2, 3 | 54 | 3x3=9, 9x3=27, 27x2=54 | Cadena x3 |
| 8 | 2, 3, 5 | 90 | 2x3=6... no. 2x5=10, 10x9=90, 9=3x3 | Arbre |
| 9 | 2, 3 | 72 | 2x2x2=8, 3x3=9, 8x9=72 | Factorització prima |
| 10 | 2, 5 | 200 | 5x5=25, 2x2x2=8, 25x8=200 | Arbre amb potències |

### Fase 3: Cadenes i potències (NOU, ~10 nivells)
Fonts: 1-2 nombres. Objectius: 50-500. 5-8 operacions.
Es requereix construcció de potències i cadenes llargues.

| # | Fonts | Objectiu | Solució esperada | Concepte |
|---|-------|----------|-----------------|----------|
| 1 | 2 | 64 | 2x2=4, 4x2=8, 8x2=16, 16x2=32, 32x2=64 | 2^6, cadena llarga |
| 2 | 3 | 81 | 3x3=9, 9x3=27, 27x3=81 | 3^4, potència |
| 3 | 2 | 256 | Cadena de 7 multiplicacions: 2->4->8->...->256 | 2^8 |
| 4 | 2, 3 | 108 | 2x2=4, 3x3x3=27, 4x27=108 | 2^2 x 3^3 arbre |
| 5 | 2, 3 | 288 | 2^5=32, 3^2=9, 32x9=288 | Factorització prima |
| 6 | 2, 3 | 216 | 6^3: 2x3=6, 6x6=36, 36x6=216 | Cub d'un producte |
| 7 | 2, 5 | 500 | 2x5=10, 10x10=100, 100x5=500 | Potències de 10 |
| 8 | 2, 3 | 1296 | 2x3=6, 6x6=36, 36x36=1296 | 6^4 = quadrat de quadrat |
| 9 | 2, 3 | 432 | 432=16x27=2^4 x 3^3 | Doble arbre |
| 10 | 2, 5 | 1000 | 2x5=10, 10x10=100, 100x10=1000 | 10^3 |

### Fase 4: Nombres primers i residus (NOU, ~10 nivells)
Fonts: 2-3 nombres. Objectius: nombres primers o quasi-primers.
Cal combinar factorització + ajust amb suma/resta.

| # | Fonts | Objectiu | Estratègia | Concepte |
|---|-------|----------|-----------|----------|
| 1 | 2, 3, 1 | 31 | 2^5=32, 32-1=31 | Primer de Mersenne |
| 2 | 2, 5, 3 | 97 | 2x5=10, 10x10=100, 100-3=97 | Primer = compost - petit |
| 3 | 2, 3, 1 | 127 | 2^7=128, 128-1=127 | Primer de Mersenne |
| 4 | 2, 5, 1 | 251 | 5x5x5=125, 125x2=250, 250+1=251 | Primer = 2x5^3 + 1 |
| 5 | 2, 3, 1 | 191 | 2^6=64, 64x3=192, 192-1=191 | Primer = 3x2^6 - 1 |
| 6 | 2, 3, 5 | 113 | 2x3=6... hmm. 5x23=115-2? 23=? | Cal buscar camí |
| 7 | 2, 3, 1 | 255 | 2^8=256, 256-1=255 | 255=3x5x17, NO primer! Engany! |
| 8 | 2, 3, 5 | 1009 | 2x5=10, 10^3=1000, 1000+3+3+3=1009 | Primer gran |
| 9 | 2, 3 | 89 | 3^2=9, 9x10=90... no tenim 10. 2x3=6, ... | Primer difícil |
| 10 | 2, 3, 1 | 511 | 2^9=512, 512-1=511 | 511=7x73, NO primer! |

### Fase 5: Reptes extrems (NOU, ~5 nivells)
Objectius molt grans. Requereix estratègies avançades.

| # | Fonts | Objectiu | Estratègia | Ops |
|---|-------|----------|-----------|:---:|
| 1 | 2, 3 | 5832 | 18^3: 2x3^2=18, 18x18=324, 324x18=5832 | 5 |
| 2 | 2, 3, 1 | 9999 | 10000-1: (2x5)^4 - 1... no tenim 5. Alt: 9999=3x3333=3x3x1111=3x3x11x101 | molts |
| 3 | 2, 3, 5 | 2025 | 45^2: (2+3)x(3x3)=45, 45x45=2025 | 5 |
| 4 | 2, 3 | 7776 | 6^5: 2x3=6, 6^5 via cadena | 5 |
| 5 | 2, 3, 5, 1 | 10001 | 10000+1 = (2x5)^4 + 1. Cal 2+3=5 primer | 6+ |

---

## Conceptes curriculars coberts

### Cicle Superior Primària (10-12)
- Fase 1: operacions bàsiques, commutativitat
- Fase 2 (inici): múltiples, factors, primers vs compostos

### ESO 1r-2n (12-14)
- Fase 2: descomposició en factors primers
- Fase 3: potències, notació exponencial, propietats de potències

### ESO 3r-4t (14-16)
- Fase 4: nombres primers, cribratge, residus
- Fase 5: estratègies avançades, optimització

---

## Extractors progressius (inspiració Beltmatic)

A Beltmatic, els "extractors" (generadors de nombres) estan repartits pel mapa
i es van descobrint. Primer només tens l'1, i tot s'ha de construir des d'allà.
Quan desblqueges el 2, de sobte pots fer 2x2=4 molt ràpid. Quan arriba el 3,
s'obren potències de 3, múltiples de 6, etc.

### Proposta per a SumSum

Les fonts disponibles NO es defineixen per nivell individual, sinó que es
**desbloquegen progressivament** amb el progrés del jugador:

| Progrés | Extractors disponibles | Capacitat |
|---------|----------------------|-----------|
| Inici | 1 | Tot des de 1. Lent, fonamental. |
| Pack 2 | 1, 2 | Potències de 2, parells, cadenes x2 |
| Pack 3 | 1, 2, 3 | Factors de 6, potències mixtes |
| Pack 4 | 1, 2, 3, 5 | Base 10, descomposició decimal |
| Pack 5+ | 1, 2, 3, 5, 7 | Nombres grans, primers |

### Per què funciona pedagògicament

1. **Construcció des de zero**: amb només l'1, l'alumne entén que TOT es
   construeix. 1+1=2, 2+1=3, 2x2=4... aprecia el valor de cada operació.
2. **Cada extractor nou és una revelació**: "Ara que tinc el 2, ja no cal
   fer 1+1 cada cop!" → moment eureka.
3. **Escalabilitat natural**: objectius més grans fan sentit perquè el
   jugador té més eines, no perquè li donem nombres grans.
4. **Llibertat creativa**: el jugador col·loca els extractors on vol i
   decideix quins usar. El nivell defineix l'objectiu, no les fonts.

### Decisió pendent: dos modes possibles

**Mode A — Extractors fixes al mapa** (com Beltmatic):
El nivell/mapa té extractors pre-col·locats en posicions concretes. El jugador
els connecta amb cintes i operadors. Cada mapa és un puzzle espacial.

**Mode B — Extractors lliures** (el jugador els col·loca):
El jugador té un "inventari" d'extractors desbloquejats i els col·loca on vol.
Més llibertat, menys puzzle espacial.

**Mode C — Híbrid**:
Mode guiat (packs actuals) amb fonts fixes + mode lliure amb extractors
desbloquejats per al joc avançat.

---

## Principis de disseny de nivells

### 1. L'objectiu MAI ha de ser obvi
Si el jugador pot veure la solució sense pensar, el nivell és massa fàcil.
El nombre objectiu ha de requerir almenys 30 segons de reflexió per un adult.

### 2. Poques fonts, moltes operacions
2-3 fonts petites (1, 2, 3, 5) forcen el jugador a CONSTRUIR, no a COMBINAR.
El repte és matemàtic, no logístic.

### 3. Múltiples solucions, algunes millors
Tot nombre compost admet diverses descomposicions. Permetre múltiples camins
però premiar (amb estrelles?) les solucions més curtes.

### 4. Progressió per insight
Cada fase introdueix un "moment eureka":
- Fase 2: "Puc reusar la mateixa font!"
- Fase 3: "Si faig una cadena de x2, creixo exponencialment!"
- Fase 4: "No puc factoritzar un primer, he de construir un compost proper i ajustar"
- Fase 5: "Puc combinar branques paral·leles per construir nombres enormes"

### 5. Autoalimentació com a mecànica clau
Les fonts emeten boles repetidament (cada 2.5s). Això permet que una font
de valor 2 alimenti MÚLTIPLES operadors al llarg d'una cadena, construint
2, 4, 8, 16, 32... Aquesta mecànica és central per als nivells avançats.

### 6. L'espai del grid com a restricció natural
El grid 12x7 = 84 cel·les limita la llargada de les cadenes. Per a nivells
extrems (>10 operadors), caldria considerar grids més grans o scroll.
Però fins a 8-10 operadors, el grid actual és suficient.

---

## Mecàniques potencials futures

### Sistema d'estrelles
- 1 estrella: nivell completat
- 2 estrelles: completat amb <= N operadors (solució eficient)
- 3 estrelles: completat amb <= M operadors (solució òptima)

### Mode sandbox amb objectiu
"Aconsegueix el 1000. Fonts: 2, 3. Sense límit d'espai ni temps."
El jugador explora lliurement.

### Mode aleatori
Genera un nombre objectiu aleatori dins d'un rang de dificultat.
Fonts fixes (2, 3) o (2, 3, 5). El jugador resol o passa.

### Operadors nous (futur)
- **Potència** (a^b): accelera la construcció de nombres grans
- **Mòdul** (a%b): permet treballar amb residus
- **Arrel**: operació inversa de potència

---

## Referència: estratègies de Beltmatic

Jugadors avançats de Beltmatic utilitzen:

1. **Potències de 10**: construir 10 i usar-lo com a base universal
2. **Descomposició per xifres**: 453 = 4x100 + 5x10 + 3
3. **Factorització prima**: descomposar el target en producte de primers
4. **Diferència de quadrats**: a^2 - b^2 = (a+b)(a-b)
5. **Sistema binari**: construir potències de 2 i sumar les necessàries
6. **Base 64**: descomposar amb mòdul 64 per reusar blocs

Per a SumSum educatiu, les estratègies 1, 3 i 5 són les més rellevants
curricularmenti i les que els alumnes poden descobrir de forma natural.

---

## Referència: fonts consultades

- Beltmatic wiki (fandom): estructura de nivells i progressió
- Steam Community Beltmatic: estratègies de jugadors per construir nombres
- Factorization games educatius: Factor Game, Factorization Forest, Gozen
