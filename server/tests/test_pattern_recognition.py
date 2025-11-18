"""
Unit tests for Circuit Pattern Recognition
"""
import unittest
from pathlib import Path
import sys

# Add parent directory to path to import modules
sys.path.insert(0, str(Path(__file__).parent.parent))

from pattern_recognition import CircuitPatternRecognizer


class TestCircuitPatternRecognizer(unittest.TestCase):
    """Test cases for CircuitPatternRecognizer"""

    def setUp(self):
        """Set up test fixtures"""
        self.recognizer = CircuitPatternRecognizer()

    def test_identify_buck_converter(self):
        """Test identifying buck/boost converter pattern"""
        components = [
            {"designator": "L1", "value": "10uH"},
            {"designator": "D1", "value": "1N5819"},
            {"designator": "Q1", "value": "IRF530"},
            {"designator": "C1", "value": "100uF"},
            {"designator": "C2", "value": "10uF"}
        ]
        nets = []

        result = self.recognizer.identify_patterns(components, nets)

        # Should find a switching converter
        self.assertTrue(result["success"])
        self.assertGreater(len(result["patterns"]["power_supplies"]), 0)

        # Check for converter pattern
        found_converter = False
        for pattern in result["patterns"]["power_supplies"]:
            if "converter" in pattern["type"].lower():
                found_converter = True
                self.assertGreater(pattern["confidence"], 0.5)
                break

        self.assertTrue(found_converter)

    def test_identify_linear_regulator(self):
        """Test identifying linear regulator pattern"""
        components = [
            {"designator": "U1", "value": "LM7805"},
            {"designator": "C1", "value": "100uF"},
            {"designator": "C2", "value": "10uF"}
        ]
        nets = []

        result = self.recognizer.identify_patterns(components, nets)

        # Should find a linear regulator
        self.assertTrue(result["success"])
        power_supplies = result["patterns"]["power_supplies"]

        found_regulator = False
        for pattern in power_supplies:
            if pattern["type"] == "linear_regulator":
                found_regulator = True
                self.assertGreater(pattern["confidence"], 0.8)
                break

        self.assertTrue(found_regulator)

    def test_identify_ldo(self):
        """Test identifying LDO pattern"""
        components = [
            {"designator": "U1", "value": "MCP1700"},
            {"designator": "C1", "value": "1uF"},
            {"designator": "C2", "value": "1uF"}
        ]
        nets = []

        result = self.recognizer.identify_patterns(components, nets)

        # Should find an LDO
        self.assertTrue(result["success"])
        power_supplies = result["patterns"]["power_supplies"]

        found_ldo = False
        for pattern in power_supplies:
            if pattern["type"] == "ldo":
                found_ldo = True
                self.assertGreater(pattern["confidence"], 0.8)
                break

        self.assertTrue(found_ldo)

    def test_identify_usb_interface(self):
        """Test identifying USB interface pattern"""
        components = [
            {"designator": "J1", "value": "USB-C"},
            {"designator": "R1", "value": "22R"},
            {"designator": "R2", "value": "22R"}
        ]
        nets = ["USB_D+", "USB_D-", "USB_VBUS", "USB_GND"]

        result = self.recognizer.identify_patterns(components, nets)

        # Should find USB interface
        self.assertTrue(result["success"])
        interfaces = result["patterns"]["interfaces"]

        found_usb = False
        for pattern in interfaces:
            if pattern["type"] == "usb_interface":
                found_usb = True
                self.assertGreater(pattern["confidence"], 0.8)
                break

        self.assertTrue(found_usb)

    def test_identify_ethernet_interface(self):
        """Test identifying Ethernet interface pattern"""
        components = [
            {"designator": "J1", "value": "RJ45"},
            {"designator": "T1", "value": "Ethernet Transformer"}
        ]
        nets = ["ETH_TX+", "ETH_TX-", "ETH_RX+", "ETH_RX-"]

        result = self.recognizer.identify_patterns(components, nets)

        # Should find Ethernet interface
        self.assertTrue(result["success"])
        interfaces = result["patterns"]["interfaces"]

        found_eth = False
        for pattern in interfaces:
            if pattern["type"] == "ethernet_interface":
                found_eth = True
                self.assertGreater(pattern["confidence"], 0.8)
                break

        self.assertTrue(found_eth)

    def test_identify_spi_interface(self):
        """Test identifying SPI interface pattern"""
        components = []
        nets = ["SPI_MOSI", "SPI_MISO", "SPI_SCLK", "SPI_CS"]

        result = self.recognizer.identify_patterns(components, nets)

        # Should find SPI interface
        self.assertTrue(result["success"])
        interfaces = result["patterns"]["interfaces"]

        found_spi = False
        for pattern in interfaces:
            if pattern["type"] == "spi_interface":
                found_spi = True
                break

        self.assertTrue(found_spi)

    def test_identify_i2c_interface(self):
        """Test identifying I2C interface pattern"""
        components = []
        nets = ["I2C_SDA", "I2C_SCL"]

        result = self.recognizer.identify_patterns(components, nets)

        # Should find I2C interface
        self.assertTrue(result["success"])
        interfaces = result["patterns"]["interfaces"]

        found_i2c = False
        for pattern in interfaces:
            if pattern["type"] == "i2c_interface":
                found_i2c = True
                break

        self.assertTrue(found_i2c)

    def test_identify_rc_filter(self):
        """Test identifying RC filter pattern"""
        components = [
            {"designator": "R1", "value": "1k"},
            {"designator": "R2", "value": "10k"},
            {"designator": "C1", "value": "100nF"},
            {"designator": "C2", "value": "10uF"}
        ]
        nets = []

        result = self.recognizer.identify_patterns(components, nets)

        # Should find RC filter
        self.assertTrue(result["success"])
        filters = result["patterns"]["filters"]

        found_rc = False
        for pattern in filters:
            if pattern["type"] == "rc_filter":
                found_rc = True
                break

        self.assertTrue(found_rc)

    def test_identify_lc_filter(self):
        """Test identifying LC filter pattern"""
        components = [
            {"designator": "L1", "value": "10uH"},
            {"designator": "C1", "value": "100nF"},
            {"designator": "C2", "value": "10uF"}
        ]
        nets = []

        result = self.recognizer.identify_patterns(components, nets)

        # Should find LC filter
        self.assertTrue(result["success"])
        filters = result["patterns"]["filters"]

        found_lc = False
        for pattern in filters:
            if pattern["type"] == "lc_filter":
                found_lc = True
                break

        self.assertTrue(found_lc)

    def test_component_type_detection(self):
        """Test component type detection methods"""
        # Test inductor detection
        inductor = {"designator": "L1", "value": "10uH"}
        self.assertTrue(self.recognizer._is_inductor(inductor))

        # Test capacitor detection
        capacitor = {"designator": "C1", "value": "100nF"}
        self.assertTrue(self.recognizer._is_capacitor(capacitor))

        # Test resistor detection
        resistor = {"designator": "R1", "value": "1k"}
        self.assertTrue(self.recognizer._is_resistor(resistor))

        # Test diode detection
        diode = {"designator": "D1", "value": "1N4148"}
        self.assertTrue(self.recognizer._is_diode(diode))

        # Test MOSFET detection
        mosfet = {"designator": "Q1", "value": "IRF530 MOSFET"}
        self.assertTrue(self.recognizer._is_mosfet(mosfet))

        # Test regulator detection
        regulator = {"designator": "U1", "value": "LM7805"}
        self.assertTrue(self.recognizer._is_regulator_ic(regulator))

        # Test LDO detection
        ldo = {"designator": "U2", "value": "MCP1700-LDO"}
        self.assertTrue(self.recognizer._is_ldo_ic(ldo))

    def test_empty_design(self):
        """Test with no components or nets"""
        result = self.recognizer.identify_patterns([], [])

        # Should return success but no patterns
        self.assertTrue(result["success"])
        self.assertEqual(len(result["patterns"]["power_supplies"]), 0)
        self.assertEqual(len(result["patterns"]["interfaces"]), 0)
        self.assertEqual(len(result["patterns"]["filters"]), 0)
        self.assertIn("No recognizable", result["summary"])

    def test_summary_generation(self):
        """Test summary generation"""
        components = [
            {"designator": "U1", "value": "LM7805"},
            {"designator": "C1", "value": "100uF"},
            {"designator": "J1", "value": "USB-C"},
            {"designator": "R1", "value": "1k"}
        ]
        nets = ["USB_D+", "USB_D-"]

        result = self.recognizer.identify_patterns(components, nets)

        # Summary should mention patterns found
        summary = result["summary"]
        self.assertIn("Found:", summary)
        self.assertIn("power supply", summary.lower())
        self.assertIn("interface", summary.lower())

    def test_complex_design(self):
        """Test with a complex design containing multiple patterns"""
        components = [
            # Power supply
            {"designator": "U1", "value": "LM7805"},
            {"designator": "C1", "value": "100uF"},
            {"designator": "C2", "value": "10uF"},
            # Buck converter
            {"designator": "L1", "value": "10uH"},
            {"designator": "D1", "value": "1N5819"},
            {"designator": "Q1", "value": "IRF530"},
            {"designator": "C3", "value": "100uF"},
            {"designator": "C4", "value": "10uF"},
            # USB interface
            {"designator": "J1", "value": "USB-C"},
            {"designator": "R1", "value": "22R"},
            # Filters
            {"designator": "R2", "value": "1k"},
            {"designator": "C5", "value": "100nF"}
        ]
        nets = ["USB_D+", "USB_D-", "USB_VBUS"]

        result = self.recognizer.identify_patterns(components, nets)

        # Should find multiple patterns
        self.assertTrue(result["success"])
        self.assertGreater(len(result["patterns"]["power_supplies"]), 0)
        self.assertGreater(len(result["patterns"]["interfaces"]), 0)
        self.assertGreater(len(result["patterns"]["filters"]), 0)


if __name__ == '__main__':
    unittest.main()
