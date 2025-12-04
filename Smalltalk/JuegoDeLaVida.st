Object subclass: #Celula	instanceVariableNames: 'viva'	classVariableNames: ''	poolDictionaries: ''	category: 'JuegoDeLaVida'!!Celula commentStamp: 'Rodri 11/28/2025 23:42' prior: 0!Clase que representa una unidad de celula del tablero!!Celula methodsFor: 'initialization' stamp: 'Rodri 11/22/2025 14:46'!estaViva    ^ viva! !!Celula methodsFor: 'initialization' stamp: 'Rodri 11/22/2025 14:46'!initialize    super initialize.    viva := false.! !!Celula methodsFor: 'EstadoCelula' stamp: 'Rodri 11/22/2025 14:46'!alternar    viva := viva not.! !!Celula methodsFor: 'EstadoCelula' stamp: 'Rodri 11/22/2025 14:48'!matar    viva := false.! !!Celula methodsFor: 'EstadoCelula' stamp: 'Rodri 11/22/2025 14:49'!calcularProximoEstado: cantidadVecinos    "Retorna true si debe estar viva en la próxima generación"    ^ (viva and: [cantidadVecinos between: 2 and: 3])        or: [viva not and: [cantidadVecinos = 3]]! !!Celula methodsFor: 'EstadoCelula' stamp: 'Rodri 11/22/2025 14:49'!revivir    viva := true.! !Morph subclass: #JuegoDeLaVidaMorph	instanceVariableNames: 'modeloJuego tamanoCelda estaCorriendo botonPausa panelInfo'	classVariableNames: ''	poolDictionaries: ''	category: 'JuegoDeLaVida'!!JuegoDeLaVidaMorph commentStamp: 'Grupo 1.19' prior: 0!RESPONSABILIDAD:
Es la representación visual.
Se encarga de dibujar la cuadrícula, capturar clics del mouse y gestionar el bucle de tiempo.
Delega toda la lógica de reglas a la clase JuegoDeLaVida.!!JuegoDeLaVidaMorph methodsFor: 'drawing' stamp: 'Rodri 11/22/2025 14:55'!drawOn: aCanvas    | baseX baseY |    super drawOn: aCanvas.    baseX := self position x.    baseY := self position y + 50.    1 to: modeloJuego alto do: [:f |        1 to: modeloJuego ancho do: [:c |            | colorCelda rectCelda celula |            celula := modeloJuego celulaEn: f en: c.            colorCelda := celula estaViva                ifTrue: [Color black]                ifFalse: [Color white].                        rectCelda := Rectangle                 origin: baseX + ((c-1) * tamanoCelda) @ (baseY + ((f-1) * tamanoCelda))                extent: tamanoCelda @ tamanoCelda.                        aCanvas fillRectangle: rectCelda color: colorCelda.            aCanvas frameRectangle: rectCelda color: (Color gray alpha: 0.2)]]! !!JuegoDeLaVidaMorph methodsFor: 'inicializacion' stamp: 'Grupo 1.19'!configurarUI
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
	self addMorph: panelInfo.! !!JuegoDeLaVidaMorph methodsFor: 'inicializacion' stamp: 'Rodri 11/22/2025 14:55'!initialize    | tamano |    super initialize.    tamanoCelda := 10.        modeloJuego := Tablero new.  "👈 CAMBIO AQUÍ"    tamano := self solicitarTamanoGrilla.    modeloJuego inicializarAncho: tamano alto: tamano.        self extent: (modeloJuego ancho * tamanoCelda) @ (modeloJuego alto * tamanoCelda + 50).    self color: Color white.    self position: 200@100.    estaCorriendo := false.        self configurarUI.! !!JuegoDeLaVidaMorph methodsFor: 'inicializacion' stamp: 'Grupo 1.19'!solicitarTamanoGrilla
	"Abre un diálogo modal bloqueante pidiendo al usuario el tamaño N x N."
	| entrada tamano |
	entrada := UIManager default 
		request: 'Tamaño de la cuadrícula (N x N):' 
		initialAnswer: '50' 
		title: 'Configuración'.
		
	tamano := (entrada notNil and: [ entrada isAllDigits and: [ entrada notEmpty ] ])
		ifTrue: [ entrada asInteger ]
		ifFalse: [ 50 ].
		
	^ tamano min: 100 max: 10! !!JuegoDeLaVidaMorph methodsFor: 'events' stamp: 'Grupo 1.19'!handlesMouseDown: evt
	"Indica a Morphic que este objeto quiere procesar clics."
	^ true! !!JuegoDeLaVidaMorph methodsFor: 'events' stamp: 'Grupo 1.19'!mouseDown: evt
	"Evento: clic inicial."
	self pintarCeldaEn: evt position! !!JuegoDeLaVidaMorph methodsFor: 'events' stamp: 'Grupo 1.19'!mouseMove: evt
	"Evento: arrastre del mouse (pintar como lápiz)."
	evt hand hasSubmorphs ifFalse: [
		self pintarCeldaEn: evt position ]! !!JuegoDeLaVidaMorph methodsFor: 'simulacion' stamp: 'Grupo 1.19'!bucleSimulacion
	"Bucle recursivo temporal: ejecuta un paso y agenda el siguiente en 100ms."
	estaCorriendo ifTrue: [
		self avanzarSimulacion.
		self addAlarm: #bucleSimulacion after: 100 ]! !!JuegoDeLaVidaMorph methodsFor: 'simulacion' stamp: 'Grupo 1.19'!reiniciarSimulacion
	"Detiene todo y vuelve a poner el tablero en blanco."
	estaCorriendo := false.
	botonPausa label: 'Iniciar'.
	modeloJuego reiniciar.
	self actualizarInfo.
	self changed! !!JuegoDeLaVidaMorph methodsFor: 'simulacion' stamp: 'Grupo 1.19'!alternarSimulacion
	"Inicia o Pausa el bucle automático."
	estaCorriendo := estaCorriendo not.
	botonPausa label: (estaCorriendo ifTrue: ['Pausar'] ifFalse: ['Iniciar']).
	estaCorriendo ifTrue: [ self bucleSimulacion ]! !!JuegoDeLaVidaMorph methodsFor: 'simulacion' stamp: 'Grupo 1.19'!avanzarSimulacion
	"Ordena al modelo evolucionar y fuerza el redibujado de la pantalla."
	modeloJuego evolucionar.
	self actualizarInfo.
	self changed! !!JuegoDeLaVidaMorph methodsFor: 'interfaz' stamp: 'Grupo 1.19'!actualizarInfo
	"Actualiza el texto del panel inferior con estadísticas del modelo."
	panelInfo contents: 'Gen: ', modeloJuego generacion asString, ' | Pob: ', modeloJuego poblacion asString! !!JuegoDeLaVidaMorph methodsFor: 'interaccion' stamp: 'Grupo 1.19'!pintarCeldaEn: unPunto
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
				self changed ]]]! !Object subclass: #Tablero	instanceVariableNames: 'grilla ancho alto generacion'	classVariableNames: ''	poolDictionaries: ''	category: 'JuegoDeLaVida'!!Tablero commentStamp: 'Rodri 11/28/2025 23:52' prior: 0!El tablero es el encargado contener a las celulas y a su vez implementar la logica del juego.Ayuda al morph a acceder a las celulas para dibujar el juego.!!Tablero methodsFor: 'Juego' stamp: 'Rodri 11/22/2025 14:50'!alternarEn: fila en: col    (self celulaEn: fila en: col) alternar.! !!Tablero methodsFor: 'Juego' stamp: 'Rodri 11/22/2025 14:52'!evolucionar    | nuevosEstados |    nuevosEstados := Array2D rows: alto columns: ancho.        "Calcular próximo estado de cada célula"    1 to: alto do: [:f |        1 to: ancho do: [:c |            | celula vecinos proximoEstado |            celula := self celulaEn: f en: c.            vecinos := self contarVecinosEn: f en: c.            proximoEstado := celula calcularProximoEstado: vecinos.            nuevosEstados at: f at: c put: proximoEstado]].        "Aplicar nuevos estados"    1 to: alto do: [:f |        1 to: ancho do: [:c |            | celula debeVivir |            celula := self celulaEn: f en: c.            debeVivir := nuevosEstados at: f at: c.            debeVivir                 ifTrue: [celula revivir]                ifFalse: [celula matar]]].        generacion := generacion + 1.! !!Tablero methodsFor: 'Juego' stamp: 'Rodri 11/22/2025 14:50'!reiniciar    grilla := Array2D rows: alto columns: ancho.    1 to: alto do: [:f |        1 to: ancho do: [:c |            grilla at: f at: c put: Celula new]].    generacion := 0.! !!Tablero methodsFor: 'Juego' stamp: 'Rodri 11/22/2025 14:50'!inicializarAncho: w alto: h    ancho := w.    alto := h.    self reiniciar.! !!Tablero methodsFor: 'Acceso' stamp: 'Rodri 11/22/2025 14:55'!ancho^ancho! !!Tablero methodsFor: 'Acceso' stamp: 'Rodri 11/22/2025 14:55'!alto ^alto! !!Tablero methodsFor: 'Acceso' stamp: 'Rodri 11/22/2025 14:50'!poblacion    | total |    total := 0.    1 to: alto do: [:f |        1 to: ancho do: [:c |            (self celulaEn: f en: c) estaViva ifTrue: [total := total + 1]]].    ^ total! !!Tablero methodsFor: 'Acceso' stamp: 'Rodri 11/22/2025 14:50'!celulaEn: fila en: col    ^ grilla at: fila at: col! !!Tablero methodsFor: 'Acceso' stamp: 'Rodri 11/22/2025 14:58'!generacion^generacion! !!Tablero methodsFor: 'CalculoProximoEstado' stamp: 'Rodri 11/22/2025 14:51'!contarVecinosEn: fila en: col    | total |    total := 0.    (fila - 1) to: (fila + 1) do: [:f |        (col - 1) to: (col + 1) do: [:c |            ((f between: 1 and: alto) and: [c between: 1 and: ancho]) ifTrue: [                ((f ~= fila) or: [c ~= col]) ifTrue: [                    (self celulaEn: f en: c) estaViva ifTrue: [                        total := total + 1]]]]].    ^ total! !