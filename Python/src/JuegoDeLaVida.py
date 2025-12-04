import pygame
import numpy as np
from Clases import Celula, Tablero
import os

blanco = (255, 255, 255)
negro = (0, 0, 0)
gris = (151, 151, 151)
rojo = (255, 0, 0)


def dibujar_tablero(ventana, tablero, tamaño_celda, num_celda):
    for y in range(num_celda):
        for x in range(num_celda):
            celula = tablero.celulaEn(y, x)
            rect = pygame.Rect(x*tamaño_celda, y*tamaño_celda,
                               tamaño_celda, tamaño_celda)
            if celula.estaViva():
                pygame.draw.rect(ventana, blanco, rect)

            pygame.draw.rect(ventana, gris, rect, 1)


pygame.init()
info_pantalla = pygame.display.Info()
ancho = 1200
alto = 700
FPS = 30
ticksPorGen = 5
contador_ticks = 0
mouse_button_down = 0
RELOJ = pygame.time.Clock()
ejecutando = True
pausado = True
mouse_down = False
os.environ['SDL_VIDEO_CENTERED'] = '1'
font = pygame.font.Font(None, 32)


def pantalla_inicial_input() -> int:
    """
    Corre un bucle de Pygame para capturar el tamaño del tablero.
    Retorna ÚNICAMENTE el número de celdas (int) al presionar ENTER con un valor válido.
    """
    VENTANA_ANCHO_INPUT = 500
    VENTANA_ALTO_INPUT = 200
    # La ventana temporal se crea aca
    ventana = pygame.display.set_mode(
        (VENTANA_ANCHO_INPUT, VENTANA_ALTO_INPUT))
    pygame.display.set_caption("Juego de la Vida - Ingresa Tamaño")

    texto_input = "50"  # Valor por defecto
    input_rect = pygame.Rect(150, 80, 200, 40)
    activo = True
    mensaje_error = ""

    input_ejecutando = True
    while input_ejecutando:

        for evento in pygame.event.get():
            if evento.type == pygame.QUIT:
                pygame.quit()
                exit()

            if evento.type == pygame.KEYDOWN and activo:
                if evento.key == pygame.K_RETURN:

                    input_valor = texto_input if texto_input else "50"

                    try:
                        num_celdas = int(input_valor)
                        if num_celdas <= 0:
                            raise ValueError("Número no positivo")

                        # solo retorna el numero de celdas
                        return num_celdas

                    except ValueError:
                        mensaje_error = "Error: Ingresa un entero positivo."

                elif evento.key == pygame.K_BACKSPACE:
                    texto_input = texto_input[:-1]
                    mensaje_error = ""
                else:
                    if evento.unicode.isdigit() and len(texto_input) < 4:
                        texto_input += evento.unicode
                    elif evento.unicode.isdigit():
                        mensaje_error = "Advertencia: Límite de 4 dígitos."

        # --- LÓGICA DE DIBUJO DEL INPUT ---
        ventana.fill(negro)
        pygame.draw.rect(ventana, gris, input_rect, 2)

        display_text = texto_input if texto_input else "50"
        text_surface = font.render(display_text, True, blanco)
        ventana.blit(text_surface, (input_rect.x + 5, input_rect.y + 5))

        input_rect.w = max(200, text_surface.get_width() + 10)

        instruccion_surface = font.render("Tamaño del tablero", True, blanco)
        ventana.blit(instruccion_surface, (10, 40))

        if mensaje_error:
            error_surface = font.render(mensaje_error, True, rojo)
            ventana.blit(error_surface, (10, 150))

        pygame.display.flip()
        RELOJ.tick(FPS)

# INICIO DEL PROGRAMA


# 1. Ejecutar el bucle de entrada para obtener el número de celdas.
num = pantalla_inicial_input()
limite_pixeles = min(ancho, alto)
tamaño = limite_pixeles // num
# Variables finales ajustadas a la cuadrícula
ancho = num * tamaño
alto = (num * tamaño)*0.8

ventana = pygame.display.set_mode((ancho, alto))
pygame.display.set_caption("El Juego de la Vida")

tablero = Tablero(ancho=num, alto=num)


def matar_celda_en_click(pos_x, pos_y, tablero, tamaño_celda):
    celda_x = pos_x // tamaño_celda
    celda_y = pos_y // tamaño_celda

    if 0 <= celda_y < tablero.alto and 0 <= celda_x < tablero.ancho:

        (tablero.celulaEn(celda_y, celda_x)).matar()
        return True
    return False


def revivir_celda_en_click(pos_x, pos_y, tablero, tamaño_celda):
    celda_x = pos_x // tamaño_celda
    celda_y = pos_y // tamaño_celda

    if 0 <= celda_y < tablero.alto and 0 <= celda_x < tablero.ancho:

        (tablero.celulaEn(celda_y, celda_x)).revivir()
        return True
    return False


while ejecutando:
    for evento in pygame.event.get():
        if evento.type == pygame.QUIT:
            ejecutando = False

       # 1. EVENTO MOUSEBUTTONDOWN (Inicio de Clic)
        if evento.type == pygame.MOUSEBUTTONDOWN:
            posx, posy = pygame.mouse.get_pos()

            if evento.button == 1:  # Click Izquierdo (Pintar/Revivir)
                mouse_button_down = 1
                revivir_celda_en_click(posx, posy, tablero, tamaño)

            elif evento.button == 3:  # Click Derecho (Despintar/Matar)
                mouse_button_down = 3
                matar_celda_en_click(posx, posy, tablero, tamaño)

        # 2. EVENTO MOUSEBUTTONUP (Fin de Clic)
        if evento.type == pygame.MOUSEBUTTONUP:
            if evento.button in [1, 3]:
                mouse_button_down = 0  # Finaliza el arrastre/clic

        # 3. EVENTO MOUSEMOTION (Arrastre / Dibujo continuo)
        if evento.type == pygame.MOUSEMOTION and mouse_button_down != 0:
            posx, posy = pygame.mouse.get_pos()

            if mouse_button_down == 1:  # Si el botón IZQUIERDO está presionado
                revivir_celda_en_click(posx, posy, tablero, tamaño)
            elif mouse_button_down == 3:  # Si el botón DERECHO está presionado
                matar_celda_en_click(posx, posy, tablero, tamaño)

        if evento.type == pygame.KEYDOWN and evento.key == pygame.K_SPACE:
            pausado = not pausado

        if evento.type == pygame.KEYDOWN and evento.key == pygame.K_r:
            tablero.reiniciar()

        if evento.type == pygame.KEYDOWN and evento.key == pygame.K_RETURN and pausado:
            tablero.evolucionar()
            contador_ticks = 0

    if not pausado:
        contador_ticks += 1
        # 4. Evolucionar solo cuando el contador alcanza el límite
        if contador_ticks >= ticksPorGen:
            tablero.evolucionar()
            contador_ticks = 0

    ventana.fill(negro)
    dibujar_tablero(ventana, tablero, tamaño, num)

    pygame.display.set_caption(
        f"El Juego de la Vida | Gen: {tablero.generacion} | Pob: {tablero.poblacion()} | {'PAUSADO' if pausado else 'Corriendo...'}")

    pygame.display.flip()
    RELOJ.tick(FPS)

pygame.quit()
