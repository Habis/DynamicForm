/****************************************************************************************************
Desarrollado por:   VASS
Proyecto:           -
Descripción:        Interfaz para las estructuras del body del response de los distintos callouts

Cambios (Versiones)
-----------------------------------------------------------------------------------------------------
No.     Fecha           Autor                   Descripción
-----   ----------      --------------------    -----------------------------------------------------
1.0     2019-10-01		Jorge Levenfeld			Creación de la Clase.                                       
*/
public interface ResponseBody_CLS {
  ResponseBody_CLS deserializeResponseBody( String jsonBody );
}