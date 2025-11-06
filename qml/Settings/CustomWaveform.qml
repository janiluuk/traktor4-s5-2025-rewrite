import CSI 1.0
import QtQuick 2.0

Module {

//-----------------------------------------------------------------------------------------------------------------------------------
// CUSTOMIZABLE WF COLORS (In the Settings Menu of the controller --> Global Options --> Waveform Options --> Color: "Customized")
//-----------------------------------------------------------------------------------------------------------------------------------

    //Here's a useful link to get the rgba values: https://developer.mozilla.org/es/docs/Web/CSS/CSS_Colors/Herramienta_para_seleccionar_color

    function rgba(r,g,b,a) { return Qt.rgba( r/255., g/255., b/255., a ) }
    //red 0-255
    //green 0-255
    //blue 0-255
    //alpha 0.00-1.00

    property color low1:	rgba ( 17,  74, 238, 0.83)
    property color low2:	rgba ( 15,  70, 245, 0.80)
    property color mid1:	rgba ( 14, 241,  14, 0.81)
    property color mid2:	rgba ( 10, 230,  10, 0.79)
    property color high1:	rgba (178,  14, 200, 0.84)
    property color high2:	rgba (175,  12, 190, 0.82)

}
