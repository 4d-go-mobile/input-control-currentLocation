package ___PACKAGE___

import android.location.Location
import android.os.Looper
import android.view.View
import androidx.fragment.app.FragmentActivity
import com.google.android.gms.location.FusedLocationProviderClient
import com.google.android.gms.location.LocationCallback
import com.google.android.gms.location.LocationRequest
import com.google.android.gms.location.LocationResult
import com.google.android.gms.location.LocationServices
import com.google.android.gms.location.Priority
import com.qmobile.qmobiledatasync.utils.BaseKotlinInputControl
import com.qmobile.qmobiledatasync.utils.KotlinInputControl
import com.qmobile.qmobileui.utils.PermissionChecker
import java.util.concurrent.TimeUnit

@KotlinInputControl
class CurrentLocation(private val view: View) : BaseKotlinInputControl {

    override val autocomplete: Boolean = true

    private val rationaleString = "Permission required to access current location"

    private lateinit var outputCallback: (outputText: String) -> Unit

    private var fusedLocationClient: FusedLocationProviderClient =
        LocationServices.getFusedLocationProviderClient(view.context as FragmentActivity)

    private lateinit var locationCallback: LocationCallback

    @Suppress("MissingPermission")
    private fun getLocation() {
        val locationRequest = LocationRequest.create().apply {
            interval = TimeUnit.SECONDS.toMillis(2)
            fastestInterval = TimeUnit.SECONDS.toMillis(3)
            maxWaitTime = TimeUnit.SECONDS.toMillis(3)
            priority = Priority.PRIORITY_HIGH_ACCURACY
        }

        locationCallback = object : LocationCallback() {
            override fun onLocationResult(locationResult: LocationResult) {
                super.onLocationResult(locationResult)
                locationResult.lastLocation?.let {
                    proceedLocationResult(it, false)
                }
            }
        }

        fusedLocationClient.requestLocationUpdates(locationRequest, locationCallback, Looper.getMainLooper())
        fusedLocationClient.lastLocation.addOnSuccessListener { lastKnownLocation: Location? ->
            if (lastKnownLocation != null) {
                proceedLocationResult(lastKnownLocation, true)
            }
        }
    }

    private fun proceedLocationResult(location: Location, isLastKnownLocation: Boolean) {
        val latLon = "${location.latitude}, ${location.longitude}"
        outputCallback(latLon)
        if (!isLastKnownLocation) {
            fusedLocationClient.removeLocationUpdates(locationCallback)
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
        (view.context as? PermissionChecker)?.askPermission(
            permission = permission,
            rationale = rationaleString
        ) { isGranted ->
            if (isGranted) {
                canGoOn()
            }
        }
    }
}