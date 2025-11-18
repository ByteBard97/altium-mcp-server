"""
Circuit Pattern Recognition System
Recognize common circuit patterns in PCB designs using heuristic analysis
"""
from typing import Dict, List, Optional
import re


class CircuitPatternRecognizer:
    """Recognize common circuit patterns in PCB designs"""

    POWER_SUPPLY_PATTERNS = {
        "buck_converter": {
            "components": ["inductor", "diode", "mosfet", "capacitor"],
            "min_components": 4,
            "description": "Buck DC-DC converter topology"
        },
        "boost_converter": {
            "components": ["inductor", "diode", "mosfet", "capacitor"],
            "min_components": 4,
            "description": "Boost DC-DC converter topology"
        },
        "linear_regulator": {
            "components": ["regulator_ic", "capacitor"],
            "min_components": 2,
            "description": "Linear voltage regulator"
        },
        "ldo": {
            "components": ["ldo_ic", "capacitor"],
            "min_components": 2,
            "description": "Low dropout regulator"
        }
    }

    INTERFACE_PATTERNS = {
        "usb_interface": {
            "components": ["usb_connector", "resistor", "capacitor"],
            "nets": ["USB_D+", "USB_D-", "USB_VBUS"],
            "description": "USB interface circuit"
        },
        "ethernet_interface": {
            "components": ["rj45", "transformer", "resistor"],
            "nets": ["ETH_TX", "ETH_RX"],
            "description": "Ethernet interface"
        }
    }

    FILTER_PATTERNS = {
        "rc_filter": {
            "components": ["resistor", "capacitor"],
            "min_components": 2,
            "description": "RC low-pass filter"
        },
        "lc_filter": {
            "components": ["inductor", "capacitor"],
            "min_components": 2,
            "description": "LC filter"
        }
    }

    def identify_patterns(self, components: List[Dict], nets: List[str]) -> Dict:
        """Identify circuit patterns in the design"""

        patterns_found = {
            "power_supplies": [],
            "interfaces": [],
            "filters": [],
            "other": []
        }

        # Analyze power supply patterns
        patterns_found["power_supplies"] = self._find_power_patterns(components)

        # Analyze interface patterns
        patterns_found["interfaces"] = self._find_interface_patterns(components, nets)

        # Analyze filter patterns
        patterns_found["filters"] = self._find_filter_patterns(components)

        return {
            "success": True,
            "patterns": patterns_found,
            "summary": self._generate_summary(patterns_found)
        }

    def _find_power_patterns(self, components: List[Dict]) -> List[Dict]:
        """Find power supply topologies"""
        found_patterns = []

        # Look for buck/boost converters
        inductors = [c for c in components if self._is_inductor(c)]
        diodes = [c for c in components if self._is_diode(c)]
        mosfets = [c for c in components if self._is_mosfet(c)]
        caps = [c for c in components if self._is_capacitor(c)]

        if inductors and diodes and mosfets and len(caps) >= 2:
            found_patterns.append({
                "type": "buck_or_boost_converter",
                "confidence": 0.8,
                "components": [c["designator"] for c in inductors[:1] + diodes[:1] + mosfets[:1] + caps[:2]],
                "description": "Switching DC-DC converter (Buck/Boost topology detected)"
            })

        # Look for linear regulators
        regulators = [c for c in components if self._is_regulator_ic(c)]
        for reg in regulators:
            # Find nearby capacitors
            nearby_caps = caps[:2] if len(caps) >= 2 else caps
            found_patterns.append({
                "type": "linear_regulator",
                "confidence": 0.9,
                "components": [reg["designator"]] + [c["designator"] for c in nearby_caps],
                "description": f"Linear regulator: {reg.get('value', 'Unknown')}"
            })

        # Look for LDOs
        ldos = [c for c in components if self._is_ldo_ic(c)]
        for ldo in ldos:
            nearby_caps = caps[:2] if len(caps) >= 2 else caps
            found_patterns.append({
                "type": "ldo",
                "confidence": 0.95,
                "components": [ldo["designator"]] + [c["designator"] for c in nearby_caps],
                "description": f"Low-dropout regulator: {ldo.get('value', 'Unknown')}"
            })

        return found_patterns

    def _find_interface_patterns(self, components: List[Dict], nets: List[str]) -> List[Dict]:
        """Find communication interface patterns"""
        found_patterns = []

        # USB detection
        usb_nets = [n for n in nets if "USB" in n.upper() or "D+" in n or "D-" in n]
        usb_connectors = [c for c in components if self._is_usb_connector(c)]

        if usb_nets or usb_connectors:
            found_patterns.append({
                "type": "usb_interface",
                "confidence": 0.9,
                "nets": usb_nets[:5],  # Limit to first 5 nets
                "components": [c["designator"] for c in usb_connectors],
                "description": "USB interface detected"
            })

        # Ethernet detection
        eth_nets = [n for n in nets if "ETH" in n.upper() or "ENET" in n.upper() or "MDI" in n.upper()]
        rj45_connectors = [c for c in components if self._is_ethernet_connector(c)]
        eth_transformers = [c for c in components if self._is_ethernet_transformer(c)]

        if eth_nets or rj45_connectors or eth_transformers:
            found_patterns.append({
                "type": "ethernet_interface",
                "confidence": 0.9,
                "nets": eth_nets[:10],  # Limit to first 10 nets
                "components": [c["designator"] for c in rj45_connectors + eth_transformers],
                "description": "Ethernet interface detected"
            })

        # SPI detection
        spi_nets = [n for n in nets if any(x in n.upper() for x in ["SPI", "MOSI", "MISO", "SCLK", "SCK"])]
        if spi_nets:
            found_patterns.append({
                "type": "spi_interface",
                "confidence": 0.85,
                "nets": spi_nets,
                "components": [],
                "description": "SPI interface detected"
            })

        # I2C detection
        i2c_nets = [n for n in nets if any(x in n.upper() for x in ["I2C", "SDA", "SCL"])]
        if i2c_nets:
            found_patterns.append({
                "type": "i2c_interface",
                "confidence": 0.85,
                "nets": i2c_nets,
                "components": [],
                "description": "I2C interface detected"
            })

        return found_patterns

    def _find_filter_patterns(self, components: List[Dict]) -> List[Dict]:
        """Find filter circuit patterns"""
        found_patterns = []

        resistors = [c for c in components if self._is_resistor(c)]
        capacitors = [c for c in components if self._is_capacitor(c)]
        inductors = [c for c in components if self._is_inductor(c)]

        # RC filters (look for R-C combinations)
        if resistors and capacitors:
            # Simple heuristic: count potential RC pairs
            rc_count = min(len(resistors), len(capacitors))
            if rc_count > 0:
                found_patterns.append({
                    "type": "rc_filter",
                    "confidence": 0.7,
                    "components": [resistors[0]["designator"], capacitors[0]["designator"]],
                    "description": f"Potential RC filter circuits detected (approx. {rc_count} instances)"
                })

        # LC filters
        if inductors and capacitors and len(capacitors) >= 2:
            found_patterns.append({
                "type": "lc_filter",
                "confidence": 0.75,
                "components": [inductors[0]["designator"], capacitors[0]["designator"]],
                "description": "Potential LC filter circuit detected"
            })

        return found_patterns

    def _is_inductor(self, component: Dict) -> bool:
        """Check if component is an inductor"""
        designator = component.get("designator", "")
        value = component.get("value", "").upper()
        return designator.startswith("L") or "H" in value or "UH" in value or "NH" in value

    def _is_capacitor(self, component: Dict) -> bool:
        """Check if component is a capacitor"""
        designator = component.get("designator", "")
        return designator.startswith("C")

    def _is_resistor(self, component: Dict) -> bool:
        """Check if component is a resistor"""
        designator = component.get("designator", "")
        return designator.startswith("R")

    def _is_diode(self, component: Dict) -> bool:
        """Check if component is a diode"""
        designator = component.get("designator", "")
        value = component.get("value", "").upper()
        return designator.startswith("D") or "DIODE" in value

    def _is_mosfet(self, component: Dict) -> bool:
        """Check if component is a MOSFET"""
        designator = component.get("designator", "")
        value = component.get("value", "").upper()

        # Check for explicit MOSFET keywords
        mosfet_keywords = ["MOSFET", "FET", "NMOS", "PMOS"]
        if designator.startswith("Q") and any(kw in value for kw in mosfet_keywords):
            return True

        # Check for common MOSFET part number prefixes
        mosfet_prefixes = ["IRF", "SI", "BSS", "2N7", "FD"]
        if designator.startswith("Q") and any(value.startswith(prefix) for prefix in mosfet_prefixes):
            return True

        return False

    def _is_regulator_ic(self, component: Dict) -> bool:
        """Check if component is a voltage regulator IC"""
        value = component.get("value", "").upper()
        designator = component.get("designator", "")

        regulator_keywords = ["LM78", "LM79", "AMS1117", "7805", "7812", "7905", "REG"]
        return designator.startswith("U") and any(kw in value for kw in regulator_keywords)

    def _is_ldo_ic(self, component: Dict) -> bool:
        """Check if component is an LDO IC"""
        value = component.get("value", "").upper()
        designator = component.get("designator", "")

        ldo_keywords = ["LDO", "LP298", "TPS", "MCP1700"]
        return designator.startswith("U") and any(kw in value for kw in ldo_keywords)

    def _is_usb_connector(self, component: Dict) -> bool:
        """Check if component is a USB connector"""
        value = component.get("value", "").upper()
        designator = component.get("designator", "")

        return (designator.startswith("J") or designator.startswith("P")) and "USB" in value

    def _is_ethernet_connector(self, component: Dict) -> bool:
        """Check if component is an Ethernet connector"""
        value = component.get("value", "").upper()
        designator = component.get("designator", "")

        keywords = ["RJ45", "RJ-45", "ETHERNET", "ETH"]
        return (designator.startswith("J") or designator.startswith("P")) and any(kw in value for kw in keywords)

    def _is_ethernet_transformer(self, component: Dict) -> bool:
        """Check if component is an Ethernet transformer/magnetics"""
        value = component.get("value", "").upper()
        designator = component.get("designator", "")

        keywords = ["ETHERNET", "ETH", "MAGNETICS", "H1102"]
        return designator.startswith("T") and any(kw in value for kw in keywords)

    def _generate_summary(self, patterns: Dict) -> str:
        """Generate human-readable summary of found patterns"""
        summary_parts = []

        power_count = len(patterns["power_supplies"])
        if power_count > 0:
            summary_parts.append(f"{power_count} power supply circuit(s)")

        interface_count = len(patterns["interfaces"])
        if interface_count > 0:
            summary_parts.append(f"{interface_count} interface circuit(s)")

        filter_count = len(patterns["filters"])
        if filter_count > 0:
            summary_parts.append(f"{filter_count} filter circuit(s)")

        if summary_parts:
            return "Found: " + ", ".join(summary_parts)
        else:
            return "No recognizable circuit patterns found"
