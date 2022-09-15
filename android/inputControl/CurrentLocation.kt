package ___PACKAGE___

import android.location.Location
import android.view.View
import androidx.fragment.app.FragmentActivity
import com.google.android.gms.location.FusedLocationProviderClient
import com.google.android.gms.location.LocationServices
import com.qmobile.qmobiledatasync.utils.BaseInputControl
import com.qmobile.qmobiledatasync.utils.InputControl
import com.qmobile.qmobileui.ui.SnackbarHelper
import com.qmobile.qmobileui.utils.PermissionChecker

@InputControl
class CurrentLocation(private val view: View) : BaseInputControl {

    override val autocomplete: Boolean = true

    private val rationaleString = "Permission required to access current location"

    private var fusedLocationClient: FusedLocationProviderClient =
        LocationServices.getFusedLocationProviderClient(view.context as FragmentActivity)

    private lateinit var outputCallback: (outputText: String) -> Unit

    @Suppress("MissingPermission")
    private fun getLocation() {
        fusedLocationClient.lastLocation.addOnSuccessListener { location: Location? ->
            if (location != null) {
                val latLon = "+" +
                    location.latitude.toString().removePrefix("+") +
                    "-" +
                    location.longitude.toString().removePrefix("-")
                outputCallback(latLon)
            } else {
                SnackbarHelper.show(view.context as FragmentActivity, "Could not get current location")
                outputCallback("")
            }
        }
    }

    override fun process(inputValue: Any?, outputCallback: (output: Any) -> Unit) {
        requestPermission(android.Manifest.permission.ACCESS_COARSE_LOCATION) {
            requestPermission(android.Manifest.permission.ACCESS_FINE_LOCATION) {
                this.outputCallback = outputCallback
                getLocation()
            }
        }
    }

    private fun requestPermission(permission: String, canGoOn: () -> Unit) {
        (view.context as PermissionChecker?)?.askPermission(
            permission = permission,
            rationale = rationaleString
        ) { isGranted ->
            if (isGranted) {
                canGoOn()
            }
        }
    }
}
