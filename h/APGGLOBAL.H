/*�*-----------------------------------------------------------------*/
/*�* GLOBALE INCLUDE-DATEI                                           */
/*�*---------------------------------------------------------------  */
/*�*                                                                 */
/*�* AUTOR         :  x. xxxxxx                                      */
/*�*                                                                 */
/*�* ERSTELLT AM   :  xx.xx.xxxx                                     */
/*�*                                                                 */
/*�* FUNKTION      :  xxx                                            */
/*�*                                                                 */
/*�* �NDERUNGEN:                                                     */
/*�*�DATUM      VON   GRUND DER �NDERUNG                             */
/*�*                                                                 */
/*�****************************************************************  */


#ifdef __eup_windows__
 #define DLLEXPORT __declspec( dllexport )
 #define DLLIMPORT __declspec( dllimport )
#endif

#if defined __eup_linux__ || defined __eup_as400__
 #define DLLEXPORT
 #define DLLIMPORT
#endif
