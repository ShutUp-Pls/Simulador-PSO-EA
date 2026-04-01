import javax.swing.JOptionPane;

class Slider {
  String etiqueta;
  float xs, ys, ancho, alto, min, max, valor; 
  boolean arrastrando = false;
  
  Slider(String eti, float px, float py, float mi, float ma, float v) {
    etiqueta = eti;
    xs = px; ys = py; ancho = 220; alto = 12; min = mi; max = ma;
    valor = v;
  }
  
  void dibujar() {
    fill(0); textSize(13);
    text(etiqueta + ": " + nf(valor, 0, 3), xs, ys - 5);

    if (ancho >= 150) {
      float bx = xs + ancho - 25;
      float by = ys - 23; 
      fill(200); stroke(150); rect(bx, by, 25, 20, 3);
      fill(0); noStroke(); textAlign(CENTER, CENTER); textSize(14);
      text("...", bx + 12.5, by + 8);
      textAlign(LEFT, BASELINE);
    }
    
    fill(180); rect(xs, ys, ancho, alto, 5);
    float valorVisual = constrain(valor, min, max); 
    float posManilla = map(valorVisual, min, max, xs, xs + ancho);
    
    fill(arrastrando ? color(255, 0, 0) : color(68, 1, 84));
    ellipse(posManilla, ys + alto / 2, alto * 1.5, alto * 1.5);
  }
  
  boolean verificarEdit(float mx, float my) {
    if (ancho < 150) return false; 
    
    float bx = xs + ancho - 25;
    float by = ys - 23;
    if (mx >= bx && mx <= bx + 25 && my >= by && my <= by + 20) {
      String input = JOptionPane.showInputDialog("Nuevo valor para " + etiqueta + " (Rango visual: " + min + " a " + max + "):", valor);
      if (input != null) {
        try {
          input = input.replace(',', '.');
          valor = Float.parseFloat(input); 
        } catch (Exception e) {}
      }
      return true;
    }
    return false;
  }
  
  void verificarPresion(float mx, float my) {
    float valorVisual = constrain(valor, min, max);
    float pm = map(valorVisual, min, max, xs, xs + ancho);
    if (dist(mx, my, pm, ys + alto / 2) < alto * 1.5) arrastrando = true;
  }
  
  void actualizar(float mx) {
    valor = map(constrain(mx, xs, xs + ancho), xs, xs + ancho, min, max);
  }
}

class SliderTimeline extends Slider {
  SliderTimeline(String eti, float px, float py, float mi, float ma, float v) {
    super(eti, px, py, mi, ma, v);
    ancho = 225;
  }

  @Override
  void dibujar() {
    fill(0); textSize(13); textAlign(CENTER, BASELINE);
    text(etiqueta, xs + ancho / 2, ys - 15);

    float bx = xs + ancho - 25;
    float by = ys - 28; 
    fill(200); stroke(150); rect(bx, by, 25, 20, 3);
    fill(0); noStroke(); textAlign(CENTER, CENTER); textSize(14);
    text("...", bx + 12.5, by + 8);

    fill(180); textAlign(LEFT, BASELINE);
    rect(xs, ys, ancho, alto, 5);
    float valorVisual = constrain(valor, min, max);
    float posManilla = map(valorVisual, min, max, xs, xs + ancho);

    fill(arrastrando ? color(255, 0, 0) : color(68, 1, 84));
    rectMode(CENTER);
    rect(posManilla, ys + alto / 2, 8, alto * 2.5);
    rectMode(CORNER);

    fill(0); textSize(12); textAlign(CENTER, BASELINE);
    text((int)valor + " / " + (int)max, xs + ancho / 2, ys + alto + 18);
    textAlign(LEFT, BASELINE);
  }

  @Override
  boolean verificarEdit(float mx, float my) {
    float bx = xs + ancho - 25;
    float by = ys - 28;
    if (mx >= bx && mx <= bx + 25 && my >= by && my <= by + 20) {
      String input = JOptionPane.showInputDialog("Nuevo límite de evaluaciones (Debe ser mayor a " + (int)valor + "):", (int)max);
      if (input != null) {
        try {
          int nuevoLimite = Integer.parseInt(input);
          if (nuevoLimite >= (int)valor) {
            limiteEvaluaciones = nuevoLimite;
            max = nuevoLimite;
          } else {
            JOptionPane.showMessageDialog(null, "El límite no puede ser menor a la evaluación actual (" + (int)valor + ").", "Error de rango", JOptionPane.ERROR_MESSAGE);
          }
        } catch (Exception e) {}
      }
      return true;
    }
    return false;
  }

  @Override
  void verificarPresion(float mx, float my) {
    float valorVisual = constrain(valor, min, max);
    float pm = map(valorVisual, min, max, xs, xs + ancho);
    if (mx >= pm - 10 && mx <= pm + 10 && my >= ys - alto && my <= ys + alto * 2.5) {
       arrastrando = true;
    }
  }
}


class MenuDesplegable {
  float x, y, ancho, alto;
  String titulo;
  boolean desplegado = false;
  ArrayList<String> opciones;
  color colorFondo, colorTexto;

  MenuDesplegable(String _titulo, float _x, float _y, float _w, float _h, color _bg, color _fg) {
    titulo = _titulo;
    x = _x; y = _y; ancho = _w; alto = _h;
    colorFondo = _bg; colorTexto = _fg;
    opciones = new ArrayList<String>();
  }

  void setOpciones(ArrayList<String> nuevasOpciones) {
    opciones = nuevasOpciones;
  }

  float dibujar() {
    fill(colorFondo);
    noStroke();
    rect(x, y, ancho, alto, 5);
    
    fill(colorTexto);
    textAlign(CENTER, CENTER);
    textSize(14);
    text(titulo, x + ancho / 2, y + alto / 2);

    float cy = alto;

    if (desplegado) {
      for (int i = 0; i < opciones.size(); i++) {
        fill(245);
        stroke(200);
        strokeWeight(1);
        rect(x, y + cy, ancho, alto);
        
        fill(50);
        textAlign(LEFT, CENTER);
        textSize(12);
        text(opciones.get(i), x + 15, y + cy + alto / 2);
        
        cy += alto;
      }
    }
    
    textAlign(LEFT, BASELINE);
    return cy;
  }

  String verificarPresion(float mx, float my) {
    if (mx >= x && mx <= x + ancho && my >= y && my <= y + alto) {
      desplegado = !desplegado;
      return "TOGGLED";
    }

    if (desplegado) {
      float cy = alto;
      for (int i = 0; i < opciones.size(); i++) {
        if (mx >= x && mx <= x + ancho && my >= y + cy && my <= y + cy + alto) {
          desplegado = false;
          return opciones.get(i);
        }
        cy += alto;
      }
    }
    
    return null;
  }
}

class SeccionColapsable {
  String titulo;
  float x, y, ancho, alto;
  boolean desplegado;

  SeccionColapsable(String t, float px, float py, float w, boolean desp) {
    titulo = t; x = px; y = py; ancho = w; alto = 30; desplegado = desp;
  }

  void dibujar() {
    fill(225); stroke(200); rect(x, y, ancho, alto); noStroke();
    fill(0); textSize(14);
    String flecha = desplegado ? "▼   " : "▶   ";
    text(flecha + titulo, x + 10, y + 20);
  }

  boolean esPresionado(float mx, float my) {
    if (mx >= x && mx <= x + ancho && my >= y && my <= y + alto) {
      desplegado = !desplegado;
      return true;
    }
    return false;
  }
}

class SeccionColapsableEliminable extends SeccionColapsable {
  
  SeccionColapsableEliminable(String t, float px, float py, float w, boolean desp) {
    super(t, px, py, w, desp);
  }

  @Override
  void dibujar() {
    super.dibujar();
    fill(255, 100, 100);
    rect(x + ancho - 30, y + 5, 20, 20, 3);
    fill(255); 
    textAlign(CENTER, CENTER); 
    textSize(12);
    text("X", x + ancho - 20, y + 14);
    textAlign(LEFT, BASELINE);
  }

  boolean esPresionadoEliminar(float mx, float my) {
    return (mx >= x + ancho - 30 && mx <= x + ancho - 10 && my >= y + 5 && my <= y + 25);
  }
  
  @Override
  boolean esPresionado(float mx, float my) {
    if (esPresionadoEliminar(mx, my)) return false;
    return super.esPresionado(mx, my);
  }
}

class Boton {
  String texto;
  float x, y, ancho, alto, radio;
  color colBg, colTxt, colBorde;
  boolean tieneBorde;

  Boton(String t, float px, float py, float w, float h, color cb, color ct, float r) {
    texto = t; x = px; y = py; ancho = w; alto = h; radio = r;
    colBg = cb; colTxt = ct; tieneBorde = false;
  }

  Boton(String t, float px, float py, float w, float h, color cb, color ct, color border, float r) {
    this(t, px, py, w, h, cb, ct, r);
    tieneBorde = true;
    colBorde = border;
  }

  void dibujar() {
    fill(colBg);
    if (tieneBorde) stroke(colBorde); else noStroke();
    rect(x, y, ancho, alto, radio);
    
    fill(colTxt); noStroke(); textAlign(CENTER, CENTER); textSize(14);
    text(texto, x + ancho/2, y + alto/2 - 2); 
    textAlign(LEFT, BASELINE);
  }

  boolean esPresionado(float mx, float my) {
    return (mx >= x && mx <= x + ancho && my >= y && my <= y + alto);
  }
}

void dibujaOverlayParticula(Particle p) {
  if (p == null) return; 

  float screenX = map(p.x, limMin, limMax, 0, simWidth);
  float screenY = map(p.y, limMin, limMax, 0, simHeight);
  
  noFill();
  stroke(255, 204, 0);
  float grosorInercia = map(constrain(w, 0, 200), 0, 200, 1, 16);
  strokeWeight(grosorInercia);     
  ellipse(screenX, screenY, 16, 16);
  
  float screenPx = map(p.px, limMin, limMax, 0, simWidth);
  float screenPy = map(p.py, limMin, limMax, 0, simHeight);
  float screenGx = map(gbestx, limMin, limMax, 0, simWidth);
  float screenGy = map(gbesty, limMin, limMax, 0, simHeight);
  
  dibujarVectorNormal(screenX, screenY, screenPx, screenPy, color(0, 200, 0));
  stroke(0, 200, 0); noFill(); strokeWeight(2); ellipse(screenPx, screenPy, 12, 12);
  fill(0, 200, 0); noStroke(); ellipse(screenPx, screenPy, 4, 4);

  dibujarVectorNormal(screenX, screenY, screenGx, screenGy, color(0, 0, 255));
  stroke(0, 0, 255); noFill(); strokeWeight(2); ellipse(screenGx, screenGy, 12, 12);
  fill(0, 0, 255); noStroke(); ellipse(screenGx, screenGy, 4, 4);
}

void dibujarVectorNormal(float x1, float y1, float x2, float y2, color c) {
  float d = dist(x1, y1, x2, y2);
  if (d < 0.001) return;

  pushMatrix();
  translate(x1, y1);
  rotate(atan2(y2 - y1, x2 - x1));

  stroke(c);
  strokeWeight(1.5);
  strokeCap(SQUARE);
  
  float arrowSize = 8;
  float largoLinea = max(0, d - arrowSize * 0.5);
  
  line(0, 0, largoLinea, 0);

  noStroke();
  fill(c);
  triangle(d, 0, d - arrowSize, -arrowSize * 0.4, d - arrowSize, arrowSize * 0.4);

  popMatrix();
}

void dibujarParticula(Particle p) {
  if (p == null) return;
  
  float screenX = map(p.x, limMin, limMax, 0, simWidth);
  float screenY = map(p.y, limMin, limMax, 0, simHeight);
  float screenPrevX = map(p.x - p.vx, limMin, limMax, 0, simWidth);
  float screenPrevY = map(p.y - p.vy, limMin, limMax, 0, simHeight);
  
  strokeWeight(1);
  stroke(0, 0, 255);
  fill(255, 0, 0);
  ellipse(screenX, screenY, 5, 5);

  line(screenX, screenY, screenPrevX, screenPrevY);
}

void dibujarFeedbackChoque() {
  if (overscrollX == 0 && overscrollY == 0) return;
  
  float size = 40;
  noStroke();
  
  if (overscrollX > 0) {
    float alpha = constrain(overscrollX * 2, 0, 150);
    beginShape(QUADS);
    fill(0, alpha); vertex(0, 0);
    fill(0, 0);     vertex(size, 0);
    fill(0, 0);     vertex(size, simHeight);
    fill(0, alpha); vertex(0, simHeight);
    endShape();
  } else if (overscrollX < 0) {
    float alpha = constrain(abs(overscrollX) * 2, 0, 150);
    beginShape(QUADS);
    fill(0, 0);     vertex(simWidth - size, 0);
    fill(0, alpha); vertex(simWidth, 0);
    fill(0, alpha); vertex(simWidth, simHeight);
    fill(0, 0);     vertex(simWidth - size, simHeight);
    endShape();
  }
  
  if (overscrollY > 0) {
    float alpha = constrain(overscrollY * 2, 0, 150);
    beginShape(QUADS);
    fill(0, alpha); vertex(0, 0);
    fill(0, alpha); vertex(simWidth, 0);
    fill(0, 0);     vertex(simWidth, size);
    fill(0, 0);     vertex(0, size);
    endShape();
  } else if (overscrollY < 0) {
    float alpha = constrain(abs(overscrollY) * 2, 0, 150);
    beginShape(QUADS);
    fill(0, 0);     vertex(0, simHeight - size);
    fill(0, 0);     vertex(simWidth, simHeight - size);
    fill(0, alpha); vertex(simWidth, simHeight);
    fill(0, alpha); vertex(0, simHeight);
    endShape();
  }
}

void despliegaBest() {
  float bestScreenX = map(gbestx, limMin, limMax, 0, simWidth);
  float bestScreenY = map(gbesty, limMin, limMax, 0, simHeight);

  fill(0, 0, 255);
  noStroke();
  ellipse(bestScreenX, bestScreenY, 12, 12);
}

float rastrigin(float x, float y) { 
  return 20 + (x * x - 10 * cos(2 * PI * x)) + (y * y - 10 * cos(2 * PI * y));
}

void dibujarRastring() { 
  color azulOscuro = color(68, 1, 84);   
  color verde = color(33, 144, 140);     
  color amarillo = color(253, 231, 37);  
  
  
  for (float i = limMin; i < limMax; i += 0.1) { 
    for (float j = limMin; j < limMax; j += 0.1) { 
      float z = rastrigin(i, j); 
      
      color colorActual;
      
      if (z < 50) {
        float proporcion = map(z, 0, 50, 0, 1);
        colorActual = lerpColor(azulOscuro, verde, proporcion);
      } else {
        float proporcion = map(z, 50, 100, 0, 1);
        colorActual = lerpColor(verde, amarillo, proporcion);
      }
      fill(colorActual);
      noStroke(); 
      rect((i + 3) * step, (j + 3) * step, step, step); 
      
    }
  }
}

void renderSimZone() {
  background(255);
  pushMatrix();
  translate(panX, panY);
  scale(zoomLevel / 100.0);
  dibujarRastring();
  for (int i = 0; i < puntos; i++) {
    if (fl[i] == null) continue;
    fl[i].display();
  }
  if (particulaSeleccionada != null) { dibujaOverlayParticula(particulaSeleccionada); }
  despliegaBest();
  popMatrix();

  dibujarFeedbackChoque();
}

import javax.swing.JOptionPane;

boolean simulacionPausada = false;

int pedirEntero(String mensaje, int valorActual) {
  String input = JOptionPane.showInputDialog(mensaje, valorActual);
  if (input != null) {
    try { return Integer.parseInt(input);
    } catch (Exception e) {}
  }
  return valorActual;
}

class PanelLateral {
  float x, y, ancho, alto;
  float scrollY = 0;
  float contentHeight = 750;
  boolean arrastrandoScroll = false;
  float scrollBarHeight;

  SecEstadoSimulacion secEstado;
  SecParametrosPSO secParams;
  SecPezSeleccionado secStats;
  SecExportar secExportar;
  PanelGraficos panelGraficos; 

  PanelLateral(float _x, float _y, float _w, float _h) {
    x = _x;
    y = _y;
    ancho = _w; 
    alto = _h;
    
    secEstado = new SecEstadoSimulacion(x, 0, ancho - 10);
    secParams = new SecParametrosPSO(x, 0, ancho - 10);
    secStats = new SecPezSeleccionado(x, 0, ancho - 10);
    secExportar = new SecExportar(x, 0, ancho - 10);
    panelGraficos = new PanelGraficos(x, ancho);
  }

  void dibujar() {
    fill(240); noStroke(); rect(x, y, ancho, alto); 
    
    float maxScroll = max(0, contentHeight - alto);
    scrollY = constrain(scrollY, 0, maxScroll);
    scrollBarHeight = max(30, alto * (alto / max(contentHeight, alto)));
    
    if (maxScroll > 0) {
      fill(210);
      rect(x + ancho - 10, y, 10, alto);
      float knobY = map(scrollY, 0, maxScroll, 0, alto - scrollBarHeight);
      fill(arrastrandoScroll ? 120 : 160); rect(x + ancho - 10, y + knobY, 10, scrollBarHeight, 5);
    }

    clip(x, y, ancho - 10, alto); 
    pushMatrix(); translate(0, -scrollY);
    
    float cy = y;
    if (!vistaAlternativa) {
      secEstado.y = cy; secEstado.dibujar(); cy += 30;
      cy = secEstado.dibujarContenido(cy);
      
      secParams.y = cy; secParams.dibujar(); cy += 35;
      cy = secParams.dibujarContenido(cy);
      
      secStats.y = cy - 5; secStats.dibujar(); cy += 25;
      cy = secStats.dibujarContenido(cy);

      secExportar.y = cy; secExportar.dibujar(); cy += 40;
      cy = secExportar.dibujarContenido(cy);
    } else {
      cy = panelGraficos.dibujar(cy);
    }

    contentHeight = cy - y + 20;
    popMatrix(); noClip();
  }

  void presionado(float mx, float my) {
    if (my > y + alto || my < y) return;

    if (mx > x + ancho - 10) { 
      arrastrandoScroll = true;
      return; 
    }
    
    float realY = my + scrollY;
    if (vistaAlternativa) {
      panelGraficos.presionado(mx, my, realY); 
      return;
    }

    if (secEstado.esPresionado(mx, realY)) return;
    if (secEstado.verificarPresion(mx, realY)) return;
    
    if (secParams.esPresionado(mx, realY)) return;
    if (secParams.verificarPresion(mx, realY)) return;
    
    if (secStats.esPresionado(mx, realY)) return;
    if (secStats.verificarPresion(mx, realY)) return;
    
    if (secExportar.esPresionado(mx, realY)) return;
    if (secExportar.verificarPresion(mx, realY)) return;
  }

  void arrastrado(float mx, float my) {
    if (arrastrandoScroll) {
      float maxScroll = max(0, contentHeight - alto);
      float mapY = constrain(my, y, y + alto);
      scrollY = map(mapY, y, y + alto, 0, maxScroll);
    }
    else {
      if (!vistaAlternativa) { 
        secParams.arrastrado(mx, my);
      }
    }
  }

  void soltado() {
    secParams.soltado();
    arrastrandoScroll = false;
  }

  void scrollear(float cantidad) {
    float maxScroll = max(0, contentHeight - alto);
    scrollY = constrain(scrollY + cantidad, 0, maxScroll);
  }

  boolean estaArrastrandoCualquierCosa() {
    if (arrastrandoScroll) return true;
    if (secParams.estaArrastrando()) return true;
    return false;
  }
}

import javax.swing.JOptionPane;

class SecEstadoSimulacion extends SeccionColapsable {
  Boton btnAzarSemilla, btnEditSemilla, btnEditEjec, btnEditPob;

  SecEstadoSimulacion(float px, float py, float wd) {
    super("ESTADO DE SIMULACIÓN", px, py, wd, true);
    color cbBg = color(200), cbTxt = color(0), cbBorder = color(150);
    btnAzarSemilla = new Boton("AZAR", x + 185, 0, 25, 20, cbBg, cbTxt, cbBorder, 3);
    btnEditSemilla = new Boton("...", x + 215, 0, 25, 20, cbBg, cbTxt, cbBorder, 3);
    btnEditEjec    = new Boton("...", x + 215, 0, 25, 20, cbBg, cbTxt, cbBorder, 3);
    btnEditPob     = new Boton("...", x + 215, 0, 25, 20, cbBg, cbTxt, cbBorder, 3);
  }

  float dibujarContenido(float cy) {
    if (!desplegado) return cy;
    
    cy += 10; fill(0); textSize(14);
    text("Semilla: " + semillaGeneradora, x + 15, cy + 15);
    btnAzarSemilla.y = cy; btnAzarSemilla.dibujar();
    btnEditSemilla.y = cy; btnEditSemilla.dibujar();
    cy += 25;
    
    text("Ejecución: " + ejecucionActual + " / " + totalEjecuciones, x + 15, cy + 15);
    btnEditEjec.y = cy; btnEditEjec.dibujar(); 
    cy += 25;
    
    text("Población: " + puntos, x + 15, cy + 15);
    btnEditPob.y = cy; btnEditPob.dibujar(); 
    cy += 25;
    
    cy += 5;
    text("Best fitness: " + nfc(gbest, 4), x + 15, cy + 15); 
    cy += 25;
    
    text("Evals to best: " + evals_to_best, x + 15, cy + 15); 
    cy += 25;
    cy += 10;
    
    return cy;
  }

  boolean verificarPresion(float mx, float my) {
    if (!desplegado) return false;
    
    if (btnEditSemilla.esPresionado(mx, my)) {
      int nuevaSemilla = pedirEntero("Ingresa la nueva semilla:", semillaGeneradora);
      if (nuevaSemilla != semillaGeneradora) { semillaGeneradora = nuevaSemilla; reiniciarEnjambre(); }
      return true;
    }
    if (btnAzarSemilla.esPresionado(mx, my)) {
      if (JOptionPane.showConfirmDialog(null, "¿Aleatorizar la semilla y reiniciar?", "Confirmar", JOptionPane.YES_NO_OPTION) == JOptionPane.YES_OPTION) { 
        semillaGeneradora = (int) random(1000000); reiniciarEnjambre(); 
      }
      return true;
    }
    if (btnEditEjec.esPresionado(mx, my)) { 
      totalEjecuciones = pedirEntero("Límite de Ejecuciones:", totalEjecuciones); 
      return true; 
    }
    if (btnEditPob.esPresionado(mx, my)) {
      int nuevaPob = pedirEntero("Cantidad de Población:", puntos);
      if (nuevaPob > 0 && nuevaPob != puntos) {
        puntos = nuevaPob; proximosPuntos = nuevaPob; reiniciarEnjambre();
      }
      return true;
    }
    return false;
  }
}

class SecPezSeleccionado extends SeccionColapsable {

  SecPezSeleccionado(float px, float py, float wd) {
    super("PEZ SELECCIONADO", px, py, wd, true);
  }

  float dibujarContenido(float cy) {
    if (!desplegado) return cy;
    
    cy += 10;
    if (particulaSeleccionada != null) {
      fill(0); textSize(13);
      text("Fitness: " + nfc(particulaSeleccionada.fit, 4), x + 15, cy + 15); cy += 20;
      text("P. Mejor: " + nfc(particulaSeleccionada.pfit, 4), x + 15, cy + 15); cy += 20;
      text("Pos X: " + nfc(particulaSeleccionada.x, 4) + " | Y: " + nfc(particulaSeleccionada.y, 4), x + 15, cy + 15); cy += 20;
      text("Vel X: " + nfc(particulaSeleccionada.vx, 4) + " | Y: " + nfc(particulaSeleccionada.vy, 4), x + 15, cy + 15); cy += 25;
      
      fill(255, 150, 0); text("■ Inercia: 100.0%", x + 15, cy + 15); cy += 20;
      fill(0, 200, 0);   text("■ Mem. Local: " + nf(particulaSeleccionada.peso_cognitivo*100, 0, 1) + "%", x + 15, cy + 15); cy += 20;
      fill(0, 0, 255);   text("■ Soc. Global: " + nf(particulaSeleccionada.peso_social*100, 0, 1) + "%", x + 15, cy + 15); cy += 20;
    } else {
      fill(100); textSize(13);
      text("Ningún pez seleccionado.", x + 15, cy + 15);
      text("Haz click en uno en la simulación.", x + 15, cy + 30); cy += 45;
    }
    
    return cy;
  }

    @SuppressWarnings("unused")
    boolean verificarPresion(float mx, float my) {
    return false;
    }
}

class SecParametrosPSO extends SeccionColapsable {
  ArrayList<Slider> sliders;

  SecParametrosPSO(float px, float py, float wd) {
    super("PARÁMETROS PSO", px, py, wd, true);
    sliders = new ArrayList<Slider>();
    sliders.add(new Slider("Inercia (w)", x + 20, 0, 0.0, 100.0, w));
    sliders.add(new Slider("Local (C1)", x + 20, 0, 0.0, 2.0, C1));
    sliders.add(new Slider("Social (C2)", x + 20, 0, 0.0, 2.0, C2));
    sliders.add(new Slider("Vel. Max (maxv)", x + 20, 0, 0.01, 2.0, maxv));
  }

  float dibujarContenido(float cy) {
    if (!desplegado) return cy;
    
    cy += 25;
    for (Slider s : sliders) { 
      s.ys = cy; s.dibujar(); cy += 45; 
    }
    cy += 5;
    
    return cy;
  }

  boolean verificarPresion(float mx, float my) {
    if (!desplegado) return false;
    for (Slider s : sliders) {
      if (s.verificarEdit(mx, my)) {
        actualizarGlobales(); 
        return true;
      }
      s.verificarPresion(mx, my);
      if (s.arrastrando) return true;
    }
    return false;
  }

  @SuppressWarnings("unused")
  void arrastrado(float mx, float my) {
    if (!desplegado) return;
    for (Slider s : sliders) {
      if (s.arrastrando) {
        s.actualizar(mx);
        actualizarGlobales();
      }
    }
  }

  void soltado() {
    for (Slider s : sliders) {
      if (s.arrastrando) {
        registrarCambioParametros("Ajuste Parámetro PSO (" + s.etiqueta + ")");
        s.arrastrando = false;
      }
    }
  }

  void actualizarGlobales() {
    w = sliders.get(0).valor; 
    C1 = sliders.get(1).valor; 
    C2 = sliders.get(2).valor; 
    maxv = sliders.get(3).valor;
  }

  boolean estaArrastrando() {
    for (Slider s : sliders) if (s.arrastrando) return true;
    return false;
  }
}

class SecExportar extends SeccionColapsable {
  Boton btnExpCSV, btnExpJSON, btnExpXML;

  SecExportar(float px, float py, float wd) {
    super("EXPORTAR COMO...", px, py, wd, true);
    btnExpCSV = new Boton(".CSV", x + 15, 0, 60, 25, color(100, 200, 100), color(0), 5);
    btnExpJSON = new Boton(".JSON", x + 85, 0, 60, 25, color(200), color(100), 5);
    btnExpXML = new Boton(".XML", x + 155, 0, 60, 25, color(200), color(100), 5);
  }

  float dibujarContenido(float cy) {
    if (!desplegado) return cy;
    
    btnExpCSV.y = cy; btnExpCSV.dibujar();
    btnExpJSON.y = cy; btnExpJSON.dibujar();
    btnExpXML.y = cy; btnExpXML.dibujar();
    cy += 40;
    
    return cy;
  }

  boolean verificarPresion(float mx, float my) {
    if (!desplegado) return false;
    
    if (btnExpCSV.esPresionado(mx, my)) { exportarCSV(); return true; }
    if (btnExpJSON.esPresionado(mx, my) || btnExpXML.esPresionado(mx, my)) {
       JOptionPane.showMessageDialog(null, "Formato en desarrollo."); return true;
    }
    
    return false;
  }
}

class PanelControles {
  float x, y, ancho, alto;
  boolean estadoPausaPrevio = false;

  Slider sliderVelocidad, sliderZoom;
  SliderTimeline sliderTimeline;
  Boton btnPausa, btnReiniciar;

  PanelControles(float _x, float _y, float _w, float _h) {
    x = _x;
    y = _y;
    ancho = _w;
    alto = _h;
    
    sliderVelocidad = new Slider("Vel. Sim", x + 15, 0, 0.001, 5, multiplicadorVelocidad);
    sliderVelocidad.ancho = 105; 
    sliderZoom = new Slider("Zoom", x + 135, 0, minZoom, maxZoom, zoomLevel);
    sliderZoom.ancho = 105;
    sliderTimeline = new SliderTimeline("LÍNEA DE TIEMPO", x + 15, 0, 0, limiteEvaluaciones, evals);
    sliderTimeline.ancho = 225;

    btnPausa = new Boton("Pausar", x + 20, 0, 100, 28, color(200,150,0), color(255), 5);
    btnReiniciar = new Boton("Reiniciar", x + 140, 0, 100, 28, color(200,0,0), color(255), 5);
  }

  void dibujar() {
    fill(240);
    rect(x, y, ancho, alto);

    fill(0, 20); rect(x, y - 3, ancho, 3);
    fill(0, 10); rect(x, y - 6, ancho, 3);
    
    fill(225); stroke(200); rect(x, y, ancho, 30); noStroke(); 
    fill(0); textSize(14);
    text("CONTROLES DE REPRODUCCIÓN", x + 10, y + 20);
    
    float fixedY = y + 55;
    
    sliderVelocidad.ys = fixedY; sliderVelocidad.dibujar();
    sliderZoom.ys = fixedY;
    if (!sliderZoom.arrastrando) sliderZoom.valor = zoomLevel;
    sliderZoom.dibujar();
    
    fixedY += 25;
    btnPausa.texto = simulacionPausada ? "Reanudar" : "Pausar";
    btnPausa.colBg = simulacionPausada ? color(0,150,0) : color(200,150,0);
    btnPausa.x = x + 15;
    btnPausa.y = fixedY; btnPausa.dibujar();
    
    btnReiniciar.x = x + 135; btnReiniciar.y = fixedY;
    btnReiniciar.dibujar();

    fixedY += 70;
    sliderTimeline.ys = fixedY;
    if (!sliderTimeline.arrastrando) {
      sliderTimeline.valor = evals;
      sliderTimeline.max = limiteEvaluaciones;
    }
    sliderTimeline.dibujar();
  }

  void presionado(float mx, float my) {
    if (my >= y && my <= y + alto && mx >= x && mx <= x + ancho) {
      if (sliderVelocidad.verificarEdit(mx, my)) { multiplicadorVelocidad = sliderVelocidad.valor; return; }
      if (sliderZoom.verificarEdit(mx, my)) { 
        zoomLevel = sliderZoom.valor;
        if (zoomLevel <= umbralResetZoom) { panX = 0; panY = 0; }
        return;
      }
      if (sliderTimeline.verificarEdit(mx, my)) return;

      boolean estabaArrastrando = sliderTimeline.arrastrando;
      sliderTimeline.verificarPresion(mx, my);
      if (!estabaArrastrando && sliderTimeline.arrastrando) {
        estadoPausaPrevio = simulacionPausada; simulacionPausada = true;
      }
      
      sliderVelocidad.verificarPresion(mx, my); 
      sliderZoom.verificarPresion(mx, my);
      
      if (btnPausa.esPresionado(mx, my)) { simulacionPausada = !simulacionPausada; return; }
      if (btnReiniciar.esPresionado(mx, my)) {
        ejecucionActual = 1;
        resultados.clearRows(); 
        simulacionPausada = false; reiniciarEnjambre();
        return;
      }
    }
  }

  @SuppressWarnings("unused")
  void arrastrado(float mx, float my) {
    if (sliderVelocidad.arrastrando) {
      sliderVelocidad.actualizar(mx);
      multiplicadorVelocidad = sliderVelocidad.valor;
    }
    if (sliderZoom.arrastrando) {
      sliderZoom.actualizar(mx);
      zoomLevel = sliderZoom.valor;
      if (zoomLevel <= umbralResetZoom) { panX = 0; panY = 0; }
    }
    if (sliderTimeline.arrastrando) { 
      sliderTimeline.actualizar(mx);
    }
  }

  void soltado() {
    if (sliderVelocidad.arrastrando || sliderZoom.arrastrando) registrarCambioParametros("Ajuste Deslizador");
    
    if (sliderTimeline.arrastrando) {
      registrarCambioParametros("Exploración Línea de Tiempo");
      saltarAEvaluacion((int)sliderTimeline.valor);
      sliderTimeline.arrastrando = false;
      simulacionPausada = estadoPausaPrevio;
    }
  
    sliderVelocidad.arrastrando = false; 
    sliderZoom.arrastrando = false;
  }
}

class ColumnaData {
  String nombre; boolean visible; color c;
  ColumnaData(String n, color col) { nombre = n; visible = false; c = col; }
}
class GraficoData {
  String titulo; Table tabla; String colX;
  ArrayList<ColumnaData> columnasY = new ArrayList<ColumnaData>();
  float yPos = 0, altoControles = 0;
  color[] paleta = { color(255,0,0), color(0,0,255), color(0,150,0), color(255,150,0), color(150,0,200), color(0,150,200) };
  
  SeccionColapsableEliminable seccion;

  GraficoData(String t) { 
    titulo = t;
    seccion = new SeccionColapsableEliminable(titulo, 0, 0, 0, true);
  }

  void inicializarColumnas() {
    if (tabla == null) return;
    int cIdx = 0;
    for (int i = 0; i < tabla.getColumnCount(); i++) {
      String nom = tabla.getColumnTitle(i);
      if (!nom.equals("Accion_Usuario") && !nom.equals(colX)) {
        columnasY.add(new ColumnaData(nom, paleta[cIdx % paleta.length])); cIdx++;
      }
    }
    if (!columnasY.isEmpty()) columnasY.get(0).visible = true;
  }

    void dibujarControlesPanel(float px, float py, float pw) {
    yPos = py;
    
    seccion.x = px; seccion.y = py; seccion.ancho = pw;
    seccion.dibujar();
    
    float cy = py + seccion.alto;

    if (seccion.desplegado) {
      cy += 15;
      
      textAlign(LEFT, CENTER);
      for (ColumnaData col : columnasY) {
        fill(col.visible ? col.c : color(200));
        rect(px + 10, cy, 12, 12, 2);
        fill(0); textSize(12);
        text(col.nombre, px + 30, cy + 5); 
        cy += 22;
      }
      cy += 5;
    }
    
    altoControles = cy - py; 
    textAlign(LEFT, BASELINE);
  }
  
  void verificarClicColumnas(float mx, float my, float px, float pw) {
    if (!seccion.desplegado) return;
    
    float cy = yPos + seccion.alto;
    cy += 15;
    
    for (ColumnaData col : columnasY) {

      if (mx >= px + 10 && mx <= px + pw - 10 && my >= cy && my <= cy + 15) { 
        col.visible = !col.visible;
      }
      cy += 22;
    }
  }

  void dibujarGrafico(float px, float py, float pw, float ph) {
    fill(255);
    stroke(200);
    rect(px, py, pw, ph, 8);

    fill(0);
    textSize(14);
    textAlign(LEFT, TOP);
    text(titulo, px + 15, py + 15);

    if (tabla == null || tabla.getRowCount() < 2) {
        fill(150);
        textAlign(CENTER, CENTER);
        text("Insuficientes datos para graficar.", px + pw/2, py + ph/2);
        textAlign(LEFT, BASELINE);
        return;
    }

    int columnasActivas = 0;
    for (ColumnaData c : columnasY) if (c.visible) columnasActivas++;

    if (columnasActivas == 0) {
        fill(150);
        textAlign(CENTER, CENTER);
        text("Selecciona al menos una columna en el panel.", px + pw/2, py + ph/2);
        textAlign(LEFT, BASELINE);
        return;
    }

    float minX = tabla.getRow(0).getFloat(colX);
    float maxX = tabla.getRow(tabla.getRowCount()-1).getFloat(colX);
    if (minX == maxX) maxX += 1;

    float gx = px + 60, gy = py + 40, gw = pw - 80, gh = ph - 70;

    if (titulo.equals("Historial de Parámetros")) {
        float altoCarril = gh / columnasActivas;
        int carrilActual = 0;

        stroke(150);
        strokeWeight(1);
        line(gx, gy + gh, gx + gw, gy + gh);

        fill(100);
        textSize(10);
        textAlign(CENTER, TOP);
        text((int)minX, gx, gy + gh + 5);
        text((int)maxX, gx + gw, gy + gh + 5);
        
        textSize(12);
        fill(50);
        text(colX, gx + gw / 2, gy + gh + 10);

        for (ColumnaData col : columnasY) {
            if (!col.visible) continue;
            float yCentroCarril = gy + (carrilActual * altoCarril) + (altoCarril / 2);
            
            stroke(230);
            strokeWeight(1);
            line(gx, yCentroCarril, gx + gw, yCentroCarril);

            fill(col.c);
            textAlign(RIGHT, CENTER);
            textSize(11);
            text(col.nombre, gx - 10, yCentroCarril);

            FloatList pxList = new FloatList();
            FloatList valList = new FloatList();
            float valorAnterior = Float.NaN;
            
            for (TableRow row : tabla.rows()) {
                float val = row.getFloat(col.nombre);
                if (Float.isNaN(valorAnterior) || val != valorAnterior) {
                    float xVal = row.getFloat(colX);
                    float plotX = map(xVal, minX, maxX, gx, gx + gw);
                    pxList.append(plotX);
                    valList.append(val);
                    valorAnterior = val;
                }
            }

            for (int j = 0; j < pxList.size(); j++) {
                float pX = pxList.get(j);
                float pVal = valList.get(j);
                
                fill(col.c);
                noStroke();
                ellipse(pX, yCentroCarril, 8, 8);

                boolean dibujarTexto = false;
                if (j == pxList.size() - 1) {
                    dibujarTexto = true;
                } else {
                    float nextPx = pxList.get(j + 1);
                    if (nextPx - pX > 60) {
                        dibujarTexto = true;
                    }
                }
                
                if (dibujarTexto) {
                    fill(0);
                    textAlign(CENTER, BOTTOM);
                    String textoValor = (pVal % 1 == 0) ? str((int)pVal) : str(pVal);
                    text(textoValor, pX, yCentroCarril - 8);
                }
            }
            carrilActual++;
        }

        textAlign(LEFT, BASELINE);
        return;
    }

    float minY = Float.MAX_VALUE;
    float maxY = -Float.MAX_VALUE;

    for (TableRow row : tabla.rows()) {
        for (ColumnaData col : columnasY) {
            if (col.visible) {
                float val = row.getFloat(col.nombre);
                if (val < minY) minY = val;
                if (val > maxY) maxY = val;
            }
        }
    }

    if (minY == Float.MAX_VALUE) return;
    if (minY == maxY) {
        minY -= 1;
        maxY += 1;
    }

    stroke(150);
    strokeWeight(1);
    line(gx, gy, gx, gy + gh);
    line(gx, gy + gh, gx + gw, gy + gh);

    fill(100);
    textSize(10);
    textAlign(RIGHT, CENTER);
    text(nfc(maxY, 2), gx - 5, gy);
    text(nfc(minY, 2), gx - 5, gy + gh);

    textAlign(CENTER, TOP);
    text((int)minX, gx, gy + gh + 5);
    text((int)maxX, gx + gw, gy + gh + 5);

    textSize(12);
    fill(50);
    text(colX, gx + gw / 2, gy + gh + 10);

    noFill();
    strokeWeight(2);

    for (ColumnaData col : columnasY) {
        if (col.visible) {
            stroke(col.c);
            beginShape();
            for (TableRow row : tabla.rows()) {
                float xVal = row.getFloat(colX);
                float yVal = row.getFloat(col.nombre);
                float plotX = map(xVal, minX, maxX, gx, gx + gw);
                float plotY = map(yVal, minY, maxY, gy + gh, gy);
                vertex(plotX, plotY);
            }
            endShape();
        }
    }

    strokeWeight(1);
    noStroke();
    textAlign(LEFT, BASELINE);
  }
}

void renderGrfZone() {
  background(245);
  pushMatrix();
  translate(0, -scrollGraficos);
  
  float gy = 20;
  ArrayList<GraficoData> graficosActivos = gui.panelLateral.panelGraficos.listaGraficos;
  
  for (int i = 0; i < graficosActivos.size(); i++) {
    GraficoData g = graficosActivos.get(i);
    g.dibujarGrafico(20, gy, simWidth - 40, 250);
    gy += 280;
  }
  
  if (graficosActivos.isEmpty()) {
    fill(150);
    textAlign(CENTER, CENTER); textSize(20);
    text("AÑADE UN GRÁFICO DESDE EL PANEL", simWidth/2, simHeight/2);
    textAlign(LEFT, BASELINE);
  }
  
  popMatrix();
}

import java.util.ArrayList;

class PanelGraficos {
  float x, ancho;
  ArrayList<GraficoData> listaGraficos;
  MenuDesplegable menuAddGrafico;
  SecExportar secExportar;

  PanelGraficos(float _x, float _ancho) {
    x = _x;
    ancho = _ancho;
    listaGraficos = new ArrayList<GraficoData>();

    menuAddGrafico = new MenuDesplegable("+ Añadir Nuevo Gráfico", x + 15, 0, ancho - 30, 30, color(68, 1, 84), color(255));
    secExportar = new SecExportar(x + 5, 0, ancho - 10);
  }

  float dibujar(float cy) {
    cy += 15;
    
    ArrayList<String> opciones = new ArrayList<String>();
    opciones.add("Historial de Parámetros");
    opciones.add("Resultados Globales");
    if (historialTicks != null) {
      for (int i = 0; i < historialTicks.size(); i++) {
        opciones.add("Historial de Ticks - Ejecución " + (i + 1));
      }
    }
    menuAddGrafico.setOpciones(opciones);
    
    menuAddGrafico.y = cy; 
    cy += menuAddGrafico.dibujar();
    cy += 15;
    
    fill(0);
    textSize(14);
    text("GRÁFICOS ACTIVOS", x + 15, cy + 15);
    cy += 30;

    for (int i = 0; i < listaGraficos.size(); i++) {
      GraficoData g = listaGraficos.get(i);
      g.dibujarControlesPanel(x + 5, cy, ancho - 10);
      cy += g.altoControles;
    }
    
    secExportar.y = cy;
    secExportar.dibujar(); 
    cy += secExportar.alto + 10;
    cy = secExportar.dibujarContenido(cy);
    cy += 20;
    
    return cy;
  }

  @SuppressWarnings("unused")
  void presionado(float mx, float my, float realY) {
    String resultadoMenu = menuAddGrafico.verificarPresion(mx, realY);
    if (resultadoMenu != null) {
      if (!resultadoMenu.equals("TOGGLED")) {
        agregarNuevoGrafico(resultadoMenu);
      }
      return; 
    }
    
    if (secExportar.esPresionado(mx, realY)) return;
    if (secExportar.verificarPresion(mx, realY)) return;

    for (int i = 0; i < listaGraficos.size(); i++) {
      GraficoData g = listaGraficos.get(i);
      
      if (g.seccion.esPresionadoEliminar(mx, realY)) {
        listaGraficos.remove(i);
        return;
      }
      
      if (g.seccion.esPresionado(mx, realY)) {
        return;
      }

      g.verificarClicColumnas(mx, realY, x, ancho);
    }
  }

  void agregarNuevoGrafico(String seleccion) {
    GraficoData g = new GraficoData(seleccion);

    if (seleccion.equals("Historial de Parámetros")) {
       g.tabla = historialParametros; 
       g.colX = "Frame_Tick";
    } else if (seleccion.equals("Resultados Globales")) {
       g.tabla = resultados; 
       g.colX = "Ejecucion";
    } else {
       int idx = Integer.parseInt(seleccion.split(" ")[5]) - 1;
       g.tabla = historialTicks.get(idx); 
       g.colX = "Evaluaciones";
    }
    
    g.inicializarColumnas();
    listaGraficos.add(g);
  }
}

boolean arrastrandoFondo = false;
Particle particulaSeleccionada = null;
float panOffsetX, panOffsetY;
float overscrollX = 0, overscrollY = 0;

void mousePressed() {
  if (mouseX >= simWidth || (gui != null && gui.btnCambiarVista != null && gui.btnCambiarVista.esPresionado(mouseX, mouseY))) {
    gui.presionado(mouseX, mouseY);
    return;
  }

  if (!vistaAlternativa) {
    if (mouseButton == LEFT) {
      boolean particulaClickeada = false;

      for (int i = 0; i < puntos; i++) {
        if (fl[i] == null) continue;
        
        float screenX = map(fl[i].x, limMin, limMax, 0, simWidth);
        float screenY = map(fl[i].y, limMin, limMax, 0, simHeight);
        float realX = (screenX * (zoomLevel / 100.0)) + panX;
        float realY = (screenY * (zoomLevel / 100.0)) + panY;
        
        if (dist(mouseX, mouseY, realX, realY) < 10) {
          particulaSeleccionada = fl[i];
          particulaClickeada = true;
          break;
        }
      }

      if (!particulaClickeada && zoomLevel > 100) {
        arrastrandoFondo = true;
        panOffsetX = mouseX - panX;
        panOffsetY = mouseY - panY;
      }
      
    } else if (mouseButton == RIGHT) {
      particulaSeleccionada = null;
    }
  }
}

void mouseDragged() {
  if (mouseX >= simWidth || (gui != null && gui.panelLateral.estaArrastrandoCualquierCosa())) {
    gui.arrastrado(mouseX, mouseY);
  } 
  else if (arrastrandoFondo && !vistaAlternativa) {
    float intendedPanX = mouseX - panOffsetX;
    float intendedPanY = mouseY - panOffsetY;
    
    float factorZoom = zoomLevel / 100.0;
    float minPanX = simWidth - (simWidth * factorZoom);
    float minPanY = simHeight - (simHeight * factorZoom);

    overscrollX = 0;
    if (intendedPanX > 0) overscrollX = intendedPanX;
    else if (intendedPanX < minPanX) overscrollX = intendedPanX - minPanX;
    
    overscrollY = 0;
    if (intendedPanY > 0) overscrollY = intendedPanY;
    else if (intendedPanY < minPanY) overscrollY = intendedPanY - minPanY;
    
    panX = constrain(intendedPanX, minPanX, 0);
    panY = constrain(intendedPanY, minPanY, 0);
  }
}

void mouseReleased() {
  arrastrandoFondo = false;
  overscrollX = 0;
  overscrollY = 0;
  if (gui != null) gui.soltado();
}

void mouseWheel(MouseEvent event) {
  float e = event.getCount();

  if (mouseX >= simWidth) {
    if (gui != null) gui.scrollear(e * 30);
    return;
  }

  if (vistaAlternativa) {
    scrollGraficos += e * 40;
    scrollGraficos = max(0, scrollGraficos);
  } else {
    zoomLevel = constrain(zoomLevel - (e * 10), minZoom, maxZoom);
    
    if (zoomLevel <= umbralResetZoom) { 
      panX = 0; 
      panY = 0;
    } else {
      float factorZoom = zoomLevel / 100.0;
      float minPanX = simWidth - (simWidth * factorZoom);
      float minPanY = simHeight - (simHeight * factorZoom);
      panX = constrain(panX, minPanX, 0);
      panY = constrain(panY, minPanY, 0);
    }
  }
}

import javax.swing.JOptionPane;

Table resultados;
Table historialParametros;
ArrayList<Table> historialTicks = new ArrayList<Table>();
Table tickActual;

void iniciarTablasExportacion() {
  if (resultados == null) {
    resultados = new Table();
    resultados.addColumn("Ejecucion");
    resultados.addColumn("Mejor_Fitness");
    resultados.addColumn("Evals_al_Mejor");
    resultados.addColumn("GBest_X_Final");
    resultados.addColumn("GBest_Y_Final");
    resultados.addColumn("Evals_Desperdiciadas");
    resultados.addColumn("Distancia_Optimo_Real");
  }

  if (historialParametros == null) {
    historialParametros = new Table();
    historialParametros.addColumn("Frame_Tick");
    historialParametros.addColumn("Accion_Usuario");
    historialParametros.addColumn("Semilla");
    historialParametros.addColumn("Poblacion");
    historialParametros.addColumn("Ejecucion_Actual");
    historialParametros.addColumn("Inercia_w");
    historialParametros.addColumn("C1");
    historialParametros.addColumn("C2");
    historialParametros.addColumn("VelMax");
    historialParametros.addColumn("Evals_Actuales");
    historialParametros.addColumn("GlobalBest_Actual");
    historialParametros.addColumn("VelocidadSim");
    historialParametros.addColumn("GBest_X");
    historialParametros.addColumn("GBest_Y");
    historialParametros.addColumn("Fitness_Medio");
    historialParametros.addColumn("Velocidad_Media");
    historialParametros.addColumn("Peso_Inercia_Medio");
    historialParametros.addColumn("Peso_Cog_Medio");
    historialParametros.addColumn("Peso_Soc_Medio");
  }
}

void iniciarTablaTickNuevo() {
  if (historialTicks == null) iniciarTablasExportacion();
  tickActual = new Table();

  tickActual.addColumn("Evaluaciones");
  tickActual.addColumn("Mejor_Fitness_Global");
  tickActual.addColumn("GBest_X");
  tickActual.addColumn("GBest_Y");
  tickActual.addColumn("Fitness_Medio");
  tickActual.addColumn("Velocidad_Media");
  tickActual.addColumn("Peso_Inercia_Medio");
  tickActual.addColumn("Peso_Cog_Medio");
  tickActual.addColumn("Peso_Soc_Medio");
  
  historialTicks.add(tickActual);
}

void limpiarTablasExportacion() {
  resultados.clearRows();
  historialParametros.clearRows();
  if (historialTicks != null) historialTicks.clear();
  registrarCambioParametros("Reinicio de lote de exportación");
}

void registrarDatoTick() {
  if (tickActual == null) return;

  float sumFit = 0, sumVel = 0;
  float sumInercia = 0, sumCog = 0, sumSoc = 0;
  int count = 0;
  
  if (fl != null) {
    for (int i = 0; i < puntos; i++) {
      if (fl[i] == null) continue;
      sumFit += fl[i].fit;
      sumVel += dist(0, 0, fl[i].vx, fl[i].vy);
      sumInercia += fl[i].peso_inercia;
      sumCog += fl[i].peso_cognitivo;
      sumSoc += fl[i].peso_social;
      count++;
    }
  }
  
  float fitMedio = count > 0 ? sumFit / count : 0;
  float velMedia = count > 0 ? sumVel / count : 0;
  float inerciaMedia = count > 0 ? sumInercia / count : 0;
  float cogMedio = count > 0 ? sumCog / count : 0;
  float socMedio = count > 0 ? sumSoc / count : 0;

  if (tickActual.getRowCount() > 0) {
    TableRow ultimaFila = tickActual.getRow(tickActual.getRowCount() - 1);
    
    boolean esDiferente = 
        ultimaFila.getInt("Evaluaciones") != evals ||
        ultimaFila.getFloat("Mejor_Fitness_Global") != gbest ||
        ultimaFila.getFloat("GBest_X") != gbestx ||
        ultimaFila.getFloat("GBest_Y") != gbesty ||
        ultimaFila.getFloat("Fitness_Medio") != fitMedio ||
        ultimaFila.getFloat("Velocidad_Media") != velMedia;
        
    if (!esDiferente) {
      return; 
    }
  }

  TableRow fila = tickActual.addRow();
  fila.setInt("Evaluaciones", evals);
  fila.setFloat("Mejor_Fitness_Global", gbest);
  fila.setFloat("GBest_X", gbestx);
  fila.setFloat("GBest_Y", gbesty);
  fila.setFloat("Fitness_Medio", fitMedio);
  fila.setFloat("Velocidad_Media", velMedia);
  fila.setFloat("Peso_Inercia_Medio", inerciaMedia);
  fila.setFloat("Peso_Cog_Medio", cogMedio);
  fila.setFloat("Peso_Soc_Medio", socMedio);
}

void registrarCambioParametros(String accion) {
  if (historialParametros == null) iniciarTablasExportacion();

  float sumFit = 0, sumVel = 0;
  float sumInercia = 0, sumCog = 0, sumSoc = 0;
  int count = 0;
  
  if (fl != null) {
    for (int i = 0; i < puntos; i++) {
      if (fl[i] == null) continue;
      sumFit += fl[i].fit;
      sumVel += dist(0, 0, fl[i].vx, fl[i].vy);
      sumInercia += fl[i].peso_inercia;
      sumCog += fl[i].peso_cognitivo;
      sumSoc += fl[i].peso_social;
      count++;
    }
  }
  
  float fitMedio = count > 0 ? sumFit / count : 0;
  float velMedia = count > 0 ? sumVel / count : 0;
  float inerciaMedia = count > 0 ? sumInercia / count : 0;
  float cogMedio = count > 0 ? sumCog / count : 0;
  float socMedio = count > 0 ? sumSoc / count : 0;

  if (historialParametros.getRowCount() > 0 && !accion.equals("Reinicio de lote de exportación")) {
    TableRow ultimaFila = historialParametros.getRow(historialParametros.getRowCount() - 1);

    boolean esDiferente = 
        ultimaFila.getInt("Semilla") != semillaGeneradora ||
        ultimaFila.getInt("Poblacion") != puntos ||
        ultimaFila.getInt("Ejecucion_Actual") != ejecucionActual ||
        ultimaFila.getInt("Evals_Actuales") != evals ||
        ultimaFila.getFloat("GlobalBest_Actual") != gbest ||
        ultimaFila.getFloat("GBest_X") != gbestx ||
        ultimaFila.getFloat("GBest_Y") != gbesty ||
        ultimaFila.getFloat("Fitness_Medio") != fitMedio ||
        ultimaFila.getFloat("Velocidad_Media") != velMedia ||
        ultimaFila.getFloat("Inercia_w") != w ||
        ultimaFila.getFloat("C1") != C1 ||
        ultimaFila.getFloat("C2") != C2 ||
        ultimaFila.getFloat("VelMax") != maxv;
        
    if (!esDiferente) {
      return; 
    }
  }

  TableRow fila = historialParametros.addRow();
  fila.setInt("Frame_Tick", frameCount);
  fila.setString("Accion_Usuario", accion);
  fila.setInt("Semilla", semillaGeneradora);
  fila.setInt("Poblacion", puntos);
  fila.setInt("Ejecucion_Actual", ejecucionActual);
  fila.setFloat("Inercia_w", w);
  fila.setFloat("C1", C1);
  fila.setFloat("C2", C2);
  fila.setFloat("VelMax", maxv);
  fila.setInt("Evals_Actuales", evals);
  fila.setFloat("GlobalBest_Actual", gbest);
  fila.setFloat("VelocidadSim", multiplicadorVelocidad);
  fila.setFloat("GBest_X", gbestx);
  fila.setFloat("GBest_Y", gbesty);
  fila.setFloat("Fitness_Medio", fitMedio);
  fila.setFloat("Velocidad_Media", velMedia);
  fila.setFloat("Peso_Inercia_Medio", inerciaMedia);
  fila.setFloat("Peso_Cog_Medio", cogMedio);
  fila.setFloat("Peso_Soc_Medio", socMedio);
}

void registrarDatoEjecucion() {
  if (resultados == null) iniciarTablasExportacion();

  int evalsDesperdiciadas = limiteEvaluaciones - evals_to_best;
  float distanciaOptimo = dist(0, 0, gbestx, gbesty);

  TableRow nuevaFila = resultados.addRow();
  nuevaFila.setInt("Ejecucion", ejecucionActual);
  nuevaFila.setFloat("Mejor_Fitness", gbest);
  nuevaFila.setInt("Evals_al_Mejor", evals_to_best);
  nuevaFila.setFloat("GBest_X_Final", gbestx);
  nuevaFila.setFloat("GBest_Y_Final", gbesty);
  nuevaFila.setInt("Evals_Desperdiciadas", evalsDesperdiciadas);
  nuevaFila.setFloat("Distancia_Optimo_Real", distanciaOptimo);
}

void exportarCSV() {
  if (resultados == null || historialParametros == null) return;
  
  if (ejecucionActual >= totalEjecuciones && evals >= limiteEvaluaciones) {
    ejecutarGuardado();
    return;
  }
  
  Object[] opciones = {"Exportar hasta aquí", "Calcular todo y exportar", "Cancelar"};
  int eleccion = JOptionPane.showOptionDialog(null,
      "¿Deseas exportar los datos registrados hasta este momento o simular inmediatamente el resto de las ejecuciones?",
      "Opciones de Exportación",
      JOptionPane.YES_NO_CANCEL_OPTION,
      JOptionPane.QUESTION_MESSAGE, null, opciones, opciones[0]);
      
  if (eleccion == 0) {
    ejecutarGuardado();
  } else if (eleccion == 1) {
    calcularRestanteSimulacion();
    ejecutarGuardado();
  }
}

String obtenerTimestamp() {
  return year() + nf(month(), 2) + nf(day(), 2) + "_" + nf(hour(), 2) + nf(minute(), 2) + nf(second(), 2);
}

void ejecutarGuardado() {
  String timestamp = obtenerTimestamp();
  String carpeta = "data/export_" + timestamp + "/";
  saveTable(historialParametros, carpeta + "parametros.csv");
  saveTable(resultados, carpeta + "resultados_globales.csv");
  
  for (int i = 0; i < historialTicks.size(); i++) {
    saveTable(historialTicks.get(i), carpeta + "ticks_ejecucion_" + (i + 1) + ".csv");
  }

  println("Exportación exitosa en carpeta: " + carpeta);
  JOptionPane.showMessageDialog(null, "Datos exportados correctamente en la carpeta:\nexport_" + timestamp);
  
  limpiarTablasExportacion();
}

void calcularRestanteSimulacion() {
  cursor(WAIT);
  
  while (evals < limiteEvaluaciones) {
    for (int i = 0; i < puntos; i++) {
      if (fl[i] == null) continue;
      if (evals < limiteEvaluaciones) {
        fl[i].move();
        fl[i].Eval();
      }
    }
    registrarDatoTick();
  }
  registrarDatoEjecucion();

  while (ejecucionActual < totalEjecuciones) {
    ejecucionActual++;
    reiniciarEnjambre();
    
    while (evals < limiteEvaluaciones) {
      for (int i = 0; i < puntos; i++) {
        if (fl[i] == null) continue;
        if (evals < limiteEvaluaciones) {
          fl[i].move();
          fl[i].Eval();
        }
      }
      registrarDatoTick();
    }
    registrarDatoEjecucion();
  }

  simulacionPausada = true;
  ejecucionActual = 1; 
  reiniciarEnjambre();
  cursor(ARROW);
}

void preguntarExportarAlFinalizar() {
  int dialogResult = JOptionPane.showConfirmDialog(null, 
    "Se ha alcanzado el límite de ejecuciones programadas.\n¿Deseas exportar los resultados como .csv ahora?", 
    "Exportar Resultados", JOptionPane.YES_NO_OPTION);
    
  if (dialogResult == JOptionPane.YES_OPTION) { ejecutarGuardado(); }
  else { limpiarTablasExportacion(); }
}

void limpiarParametrosFuturos(int targetEval) {
  if (historialParametros == null) return;
  
  for (int i = historialParametros.getRowCount() - 1; i >= 0; i--) {
    TableRow row = historialParametros.getRow(i);
    
    if (row.getInt("Ejecucion_Actual") == ejecucionActual) {
      if (row.getInt("Evals_Actuales") > targetEval) {
        
        historialParametros.removeRow(i);
      } else {
        row.setFloat("Inercia_w", w);
        row.setFloat("C1", C1);
        row.setFloat("C2", C2);
        row.setFloat("VelMax", maxv);
        row.setInt("Poblacion", puntos);
      }
    }
  }
}