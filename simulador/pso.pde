// PSO automatizado para ejecuciones múltiples
// Dominio: -3 < xi < 7

GuiManager gui;

int semillaGeneradora;
float step;
float acumuladorPasos;
Particle[] fl; // arreglo de partículas
float scrollGraficos = 0;
float panX = 0, panY = 0;
float gbestx = 999999, gbesty = 999999, gbest = 999999; 

int puntos = 100;
int proximosPuntos = 100;  

int ejecucionActual = 1;
int totalEjecuciones = 30;

float limMin = -3.0;
float limMax = 7.0;

float w = 1.0; // inercia
float C1 = 1.0; // own
float C2 = 1.0; // social
float maxv = 0.1; 

// Aquí se declara la variable que causaba el error
int evals = 0;
int evals_to_best = 0; 

// ppt
int limiteEvaluaciones = 100000; // limite de cuanto espera


class Particle {
  float x, y, fit; // posicion actual (vector x) y aptitud (x-fitness) 
  float px, py, pfit; // posicion (vector p) y aptitud
  float vx, vy; // vector avance
  
  // Variables requeridas para el análisis en la GUI
  float v_cognitivo_x, v_cognitivo_y;
  float v_social_x, v_social_y;
  float peso_cognitivo, peso_social, peso_inercia;

  Particle() {
    x = random(limMin, limMax);
    y = random(limMin, limMax); 
    vx = random(-0.5, 0.5);
    vy = random(-0.5, 0.5);
    pfit = Float.MAX_VALUE; 
    fit = pfit;
  }

  void display() { 
    // funcion que dibuja las particulas delegada a la GUI para soportar Zoom y Paneo
    dibujarParticula(this);
  }

  float Eval() {
    evals++; // La variable ahora es reconocida globalmente
    fit = rastrigin(x, y);
    if (fit < pfit) { // aqui aplica la busqueda a mayor o menor
      pfit = fit;
      px = x;
      py = y;
    }
    if (fit < gbest) { 
      gbest = fit;
      gbestx = x;
      gbesty = y;
      evals_to_best = evals;
    }
    return fit;
  }

  void move() {
    float r1 = random(0, 1);
    float r2 = random(0, 1);
    
    // Calculo de componentes separados para estadísticas de GUI
    v_cognitivo_x = C1 * r1 * (px - x);
    v_cognitivo_y = C1 * r1 * (py - y);
    v_social_x = C2 * r2 * (gbestx - x);
    v_social_y = C2 * r2 * (gbesty - y);

    float magInercia = dist(0, 0, w * vx, w * vy);
    float magCog = dist(0, 0, v_cognitivo_x, v_cognitivo_y);
    float magSoc = dist(0, 0, v_social_x, v_social_y);
    float totalMag = magInercia + magCog + magSoc;

    if (totalMag > 0) {
      peso_cognitivo = magCog / totalMag;
      peso_social = magSoc / totalMag;
      peso_inercia = magInercia / totalMag;
    } else {
      peso_cognitivo = 0; peso_social = 0;
      peso_inercia = 0;
    }

    // actualiza velocidad (fórmula con factores de aprendizaje C1 y C2)
    vx = w * vx + v_cognitivo_x + v_social_x;
    vy = w * vy + v_cognitivo_y + v_social_y;
    
    float modu = sqrt(vx * vx + vy * vy);
    if (modu > maxv) {
      vx = (vx / modu) * maxv;
      vy = (vy / modu) * maxv;
    }
    
    // update position
    x = x + vx;
    y = y + vy;
    
    // rebota en el limite asignado usando límites dinámicos de la GUI
    if (x > limMax) { x = limMax; vx = -vx; } 
    else if (x < limMin) { x = limMin; vx = -vx; }
    
    if (y > limMax) { y = limMax; vy = -vy; } 
    else if (y < limMin) { y = limMin; vy = -vy; }
  }
}

// prepara el algortimo para iniciar una nueva búsqueda independiente
void reiniciarEnjambre() { 
  reiniciarEnjambre(true); 
}

void reiniciarEnjambre(boolean borradoCompleto) { 
  if (ejecucionActual == 1) {
    if (borradoCompleto) {
      if (historialTicks != null) {
        historialTicks.clear();
      }
      if (gui != null && gui.panelLateral != null && gui.panelLateral.panelGraficos != null) {
        gui.panelLateral.panelGraficos.listaGraficos.clear();
      }
    }
  }

  randomSeed(semillaGeneradora + ejecucionActual);
  evals = 0;
  evals_to_best = 0;
  gbest = Float.MAX_VALUE;
  
  if (fl == null || fl.length != puntos) {
    fl = new Particle[puntos];
  }
  
  particulaSeleccionada = null;
  
  for (int i = 0; i < puntos; i++) {
    fl[i] = new Particle();
    fl[i].Eval();
  }
  
  if (borradoCompleto || historialTicks == null || historialTicks.isEmpty() || ejecucionActual > historialTicks.size()) {
    iniciarTablaTickNuevo();
  } else {
    tickActual = historialTicks.get(ejecucionActual - 1);
    tickActual.clearRows();
  }
  registrarDatoTick();
}

void saltarAEvaluacion(int targetEval) {
  if (targetEval == evals) return;
  cursor(WAIT);
  if (targetEval < evals) { 
    limpiarParametrosFuturos(targetEval);
    reiniciarEnjambre(false);
  }

  while (evals < targetEval) {
    for (int i = 0; i < puntos; i++) {
      if (fl[i] == null) continue;
      if (evals < targetEval) {
        fl[i].move();
        fl[i].Eval();
      }
    }
    registrarDatoTick(); 
  }
  registrarCambioParametros("Rebobinado a eval " + targetEval);
  cursor(ARROW);
}

void setup() {
  size(860, 600);
  frameRate(30); // velocidad de la animación ajustada para GUI
  step = simWidth / 10.0;
  semillaGeneradora = (int) random(1000000);
  
  iniciarTablasExportacion();
  registrarCambioParametros("Inicio Simulación");
  gui = new GuiManager();
  reiniciarEnjambre();
}

void draw() {
  if (!simulacionPausada) {
    acumuladorPasos += multiplicadorVelocidad;
  }
  
  int pasosEnteros = floor(acumuladorPasos);
  if (pasosEnteros > 0) {
    acumuladorPasos -= pasosEnteros;
  }

  for (int p = 0; p < pasosEnteros; p++) {
    for (int i = 0; i < puntos; i++) {
      if (fl[i] == null) continue;
      if (evals < limiteEvaluaciones) {
        fl[i].move();
        fl[i].Eval();
      }
    }
    if (evals <= limiteEvaluaciones) {
      registrarDatoTick();
    }
  }
  
  if (!simulacionPausada && pasosEnteros > 0) {
      registrarCambioParametros("Tick Automático");
  }

  // dibuja componentes GUI (incluye Rastrigin y despliegaBest)
  gui.render();

  // Control de exportación al terminar
  if (evals >= limiteEvaluaciones && !simulacionPausada) {
    registrarDatoEjecucion();
    if (ejecucionActual >= totalEjecuciones) {
      simulacionPausada = true;
      preguntarExportarAlFinalizar();
      ejecucionActual = 1; 
      reiniciarEnjambre();
    } else {
      ejecucionActual++;
      reiniciarEnjambre();
    }
  }
}