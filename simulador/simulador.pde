boolean vistaAlternativa = false;
Boton btnCambiarVista;

int simWidth = 600;
int simHeight = 600;
int panelWidth = 260;

float zoomLevel = 100;
float minZoom = 100.0;
float maxZoom = 400.0;
float umbralResetZoom = 101.0;

float multiplicadorVelocidad = 0.5; 

class GuiManager {
  PanelLateral panelLateral;
  PanelControles panelControles;
  Boton btnCambiarVista;

  GuiManager() {
    float altoControles = 190;
    
    panelLateral = new PanelLateral(simWidth, 0, panelWidth, simHeight - altoControles);
    panelControles = new PanelControles(simWidth, simHeight - altoControles, panelWidth, altoControles);
    
    float miniW = 180;
    float miniX = simWidth - miniW - 15;
    btnCambiarVista = new Boton("Dashboard", miniX, simHeight - 35, miniW, 30, color(50, 150, 200), color(255), 5);
  }

  void render() {
    if (!vistaAlternativa) { renderSimZone(); }
    else { renderGrfZone(); }
    
    panelLateral.dibujar();
    panelControles.dibujar();
    
    btnCambiarVista.texto = vistaAlternativa ? "Simulación" : "Dashboard";
    btnCambiarVista.dibujar();
  }
  
  void presionado(float mx, float my) {
    if (btnCambiarVista.esPresionado(mx, my)) {
      vistaAlternativa = !vistaAlternativa;
      return;
    }
    panelControles.presionado(mx, my);
    panelLateral.presionado(mx, my);
  }
  
  void arrastrado(float mx, float my) {
    panelControles.arrastrado(mx, my);
    panelLateral.arrastrado(mx, my);
  }
  
  void soltado() {
    panelControles.soltado();
    panelLateral.soltado();
  }
  
  void scrollear(float cantidad) {
    panelLateral.scrollear(cantidad);
  }
}