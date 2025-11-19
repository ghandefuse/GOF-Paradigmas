Object subclass: #JuegoDeLaVida	instanceVariableNames: 'grilla ancho alto generacion'	classVariableNames: ''	poolDictionaries: ''	category: 'JuegoDeLaVida'!!JuegoDeLaVida commentStamp: 'Grupo 1.19' prior: 0!RESPONSABILIDAD:
Representa el modelo matemático puro del Juego de la Vida. 
Gestiona la matriz de células y las reglas de supervivencia.!!JuegoDeLaVida methodsFor: 'inicializacion' stamp: 'Grupo 1.19'!inicializarAncho: w alto: h
	"Configura las dimensiones del tablero y resetea el estado."
	ancho := w.
	alto := h.
	self reiniciar.! !!JuegoDeLaVida methodsFor: 'logica' stamp: 'Grupo 1.19'!reiniciar
	"Limpia la matriz (todas las celdas muertas) y reinicia el contador de generaciones."
	grilla := Array2D rows: alto columns: ancho element: 0.
	generacion := 0.! !!JuegoDeLaVida methodsFor: 'logica' stamp: 'Grupo 1.19'!evolucionar
	"Aplica las reglas de Conway para avanzar una generación:
	 1. Supervivencia: 2 o 3 vecinos.
	 2. Muerte: <2 (soledad) o >3 (sobrepoblación).
	 3. Nacimiento: Exactamente 3 vecinos."
	
	| nuevaGrilla |
	nuevaGrilla := Array2D rows: alto columns: ancho.
	1 to: alto do: [ :f |
		1 to: ancho do: [ :c |
			| vecinos estado nuevoEstado |
			estado := grilla at: f at: c.
			vecinos := self contarVecinosEn: f en: c.
			nuevoEstado := 0.
			
			(estado = 1 and: [ vecinos between: 2 and: 3 ]) ifTrue: [ nuevoEstado := 1 ].
			(estado = 0 and: [ vecinos = 3 ]) ifTrue: [ nuevoEstado := 1 ].
			
			nuevaGrilla at: f at: c put: nuevoEstado ]].
			
	grilla := nuevaGrilla.
	generacion := generacion + 1.! !!JuegoDeLaVida methodsFor: 'acceso' stamp: 'Grupo 1.19'!estaVivaEn: fila en: col
	"Devuelve true si la celda tiene valor 1, false si es 0."
	^ (grilla at: fila at: col) = 1! !!JuegoDeLaVida methodsFor: 'acceso' stamp: 'Grupo 1.19'!alternarEn: fila en: col
	"Invierte el estado de una celda específica (VIVA->MUERTA o MUERTA->VIVA).
	 Utilizado por la interacción del mouse."
	| actual |
	actual := grilla at: fila at: col.
	grilla at: fila at: col put: (actual = 0 ifTrue: [1] ifFalse: [0])! !!JuegoDeLaVida methodsFor: 'acceso' stamp: 'Grupo 1.19'!poblacion
	"Calcula el número total de células vivas en el tablero actual."
	| total |
	total := 0.
	1 to: alto do: [ :f |
		1 to: ancho do: [ :c | total := total + (grilla at: f at: c) ]].
	^ total! !!JuegoDeLaVida methodsFor: 'acceso' stamp: 'Grupo 1.19'!ancho
	"Retorna el ancho del tablero."
	^ ancho! !!JuegoDeLaVida methodsFor: 'acceso' stamp: 'Grupo 1.19'!alto
	"Retorna la altura del tablero."
	^ alto! !!JuegoDeLaVida methodsFor: 'acceso' stamp: 'Grupo 1.19'!generacion
	"Retorna el número de la generación actual."
	^ generacion! !!JuegoDeLaVida methodsFor: 'privado' stamp: 'Grupo 1.19'!contarVecinosEn: fila en: col
	"Calcula la suma de las 8 celdas adyacentes a la coordenada dada.
	 Maneja los bordes del tablero verificando los límites."
	| total |
	total := 0.
	(fila - 1) to: (fila + 1) do: [ :f |
		(col - 1) to: (col + 1) do: [ :c |
			((f between: 1 and: alto) and: [ c between: 1 and: ancho ]) ifTrue: [
				((f ~= fila) or: [ c ~= col ]) ifTrue: [
					total := total + (grilla at: f at: c) ]]]].
	^ total! !Morph subclass: #JuegoDeLaVidaMorph	instanceVariableNames: 'modeloJuego tamanoCelda estaCorriendo botonPausa panelInfo'	classVariableNames: ''	poolDictionaries: ''	category: 'JuegoDeLaVida'!!JuegoDeLaVidaMorph commentStamp: 'Grupo 1.19' prior: 0!RESPONSABILIDAD:
Es la representación visual.
Se encarga de dibujar la cuadrícula, capturar clics del mouse y gestionar el bucle de tiempo.
Delega toda la lógica de reglas a la clase JuegoDeLaVida.!!JuegoDeLaVidaMorph methodsFor: 'simulacion' stamp: 'Grupo 1.19'!avanzarSimulacion
	"Ordena al modelo evolucionar y fuerza el redibujado de la pantalla."
	modeloJuego evolucionar.
	self actualizarInfo.
	self changed! !!JuegoDeLaVidaMorph methodsFor: 'simulacion' stamp: 'Grupo 1.19'!alternarSimulacion
	"Inicia o Pausa el bucle automático."
	estaCorriendo := estaCorriendo not.
	botonPausa label: (estaCorriendo ifTrue: ['Pausar'] ifFalse: ['Iniciar']).
	estaCorriendo ifTrue: [ self bucleSimulacion ]! !!JuegoDeLaVidaMorph methodsFor: 'simulacion' stamp: 'Grupo 1.19'!bucleSimulacion
	"Bucle recursivo temporal: ejecuta un paso y agenda el siguiente en 100ms."
	estaCorriendo ifTrue: [
		self avanzarSimulacion.
		self addAlarm: #bucleSimulacion after: 100 ]! !!JuegoDeLaVidaMorph methodsFor: 'simulacion' stamp: 'Grupo 1.19'!reiniciarSimulacion
	"Detiene todo y vuelve a poner el tablero en blanco."
	estaCorriendo := false.
	botonPausa label: 'Iniciar'.
	modeloJuego reiniciar.
	self actualizarInfo.
	self changed! !!JuegoDeLaVidaMorph methodsFor: 'inicializacion' stamp: 'Grupo 1.19'!solicitarTamanoGrilla
	"Abre un diálogo modal bloqueante pidiendo al usuario el tamaño N x N."
	| entrada tamano |
	entrada := UIManager default 
		request: 'Tamaño de la cuadrícula (N x N):' 
		initialAnswer: '50' 
		title: 'Configuración'.
		
	tamano := (entrada notNil and: [ entrada isAllDigits and: [ entrada notEmpty ] ])
		ifTrue: [ entrada asInteger ]
		ifFalse: [ 50 ].
		
	^ tamano min: 100 max: 10! !!JuegoDeLaVidaMorph methodsFor: 'inicializacion' stamp: 'Grupo 1.19'!configurarUI
	"Crea y posiciona los botones y paneles de información."
	| panelControl botonPaso botonReset |
	
	panelControl := Morph new
		color: Color lightGray;
		extent: (self width) @ 50;
		position: self position.
		
	botonPausa := SimpleButtonMorph new
		label: 'Iniciar';
		target: self;
		actionSelector: #alternarSimulacion;
		position: self position + (10@10);
		extent: 60@30.
		
	botonPaso := SimpleButtonMorph new
		label: 'Paso';
		target: self;
		actionSelector: #avanzarSimulacion;
		position: self position + (80@10);
		extent: 60@30.
		
	botonReset := SimpleButtonMorph new
		label: 'Reset';
		target: self;
		actionSelector: #reiniciarSimulacion;
		position: self position + (150@10);
		extent: 60@30.
		
	panelInfo := StringMorph new
		contents: 'Gen: 0 | Pob: 0';
		position: self position + (220@15).
		
	self addMorph: panelControl.
	self addMorph: botonPausa.
	self addMorph: botonPaso.
	self addMorph: botonReset.
	self addMorph: panelInfo.! !!JuegoDeLaVidaMorph methodsFor: 'inicializacion' stamp: 'Grupo 1.19'!initialize
	"Constructor principal del Morph. Configura modelo, geometría y UI."
	| tamano |
	super initialize.
	tamanoCelda := 10.
	
	modeloJuego := JuegoDeLaVida new.
	tamano := self solicitarTamanoGrilla.
	modeloJuego inicializarAncho: tamano alto: tamano.
	
	self extent: (modeloJuego ancho * tamanoCelda) @ (modeloJuego alto * tamanoCelda + 50).
	self color: Color white.
	self position: 200@100.
	estaCorriendo := false.
	
	self configurarUI.! !!JuegoDeLaVidaMorph methodsFor: 'interaccion' stamp: 'Grupo 1.19'!pintarCeldaEn: unPunto
	"Traduce una coordenada de pantalla (píxeles) a una coordenada de matriz (f, c)
	 y solicita al modelo que cambie el estado de esa celda."
	| x y gridX gridY puntoRelativo |
	puntoRelativo := unPunto - (self position + (0@50)).
	x := puntoRelativo x.
	y := puntoRelativo y.

	(x >= 0 and: [ y >= 0 ]) ifTrue: [
		gridX := (x // tamanoCelda) + 1.
		gridY := (y // tamanoCelda) + 1.
		
		(gridX between: 1 and: modeloJuego ancho) ifTrue: [
			(gridY between: 1 and: modeloJuego alto) ifTrue: [
				modeloJuego alternarEn: gridY en: gridX.
				self actualizarInfo.
				self changed ]]]! !!JuegoDeLaVidaMorph methodsFor: 'interfaz' stamp: 'Grupo 1.19'!actualizarInfo
	"Actualiza el texto del panel inferior con estadísticas del modelo."
	panelInfo contents: 'Gen: ', modeloJuego generacion asString, ' | Pob: ', modeloJuego poblacion asString! !!JuegoDeLaVidaMorph methodsFor: 'events' stamp: 'Grupo 1.19'!handlesMouseDown: evt
	"Indica a Morphic que este objeto quiere procesar clics."
	^ true! !!JuegoDeLaVidaMorph methodsFor: 'events' stamp: 'Grupo 1.19'!mouseDown: evt
	"Evento: clic inicial."
	self pintarCeldaEn: evt position! !!JuegoDeLaVidaMorph methodsFor: 'events' stamp: 'Grupo 1.19'!mouseMove: evt
	"Evento: arrastre del mouse (pintar como lápiz)."
	evt hand hasSubmorphs ifFalse: [
		self pintarCeldaEn: evt position ]! !!JuegoDeLaVidaMorph methodsFor: 'drawing' stamp: 'Grupo 1.19'!drawOn: aCanvas
	"Método crítico de renderizado: Dibuja cada celda viva como un rectángulo negro."
	| baseX baseY |
	super drawOn: aCanvas.
	baseX := self position x.
	baseY := self position y + 50.

	1 to: modeloJuego alto do: [ :f |
		1 to: modeloJuego ancho do: [ :c |
			| colorCelda rectCelda |
			colorCelda := (modeloJuego estaVivaEn: f en: c)
				ifTrue: [ Color black ]
				ifFalse: [ Color white ].
			
			rectCelda := Rectangle 
				origin: baseX + ((c-1) * tamanoCelda) @ (baseY + ((f-1) * tamanoCelda))
				extent: tamanoCelda @ tamanoCelda.
			
			aCanvas fillRectangle: rectCelda color: colorCelda.
			aCanvas frameRectangle: rectCelda color: (Color gray alpha: 0.2) ]]! !