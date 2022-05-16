/****************************************************************************************************
Desarrollado por:   VASS
Proyecto:           -
Descripción:        Clase de excepción para los callouts

Cambios (Versiones)
-----------------------------------------------------------------------------------------------------
No.     Fecha           Autor                   Descripción
-----   ----------      --------------------    -----------------------------------------------------
1.0     2019-10-01		Jorge Levenfeld			Creación de la Clase.                                       
*/
public class ServiceException extends Exception {

  public String aplicacionOrigen = 'OB';
  public String webServiceName;
  public String requestBody;
  public String responseBody;
  public Integer statusCode;
  public String status;

}